import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/providers/post_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final FocusNode _textFieldFocusNode = FocusNode(); // 텍스트 필드 포커스를 관리하는 노드
  bool _isFocused = false; // 텍스트 필드가 포커스를 가지고 있는지 확인
  List<File> _selectedImages = []; // 선택한 사진 파일들을 저장하는 리스트
  TextEditingController _postController =
      TextEditingController(); // 게시글 내용을 관리하는 컨트롤러
  bool _isUploading = false; // 업로드 진행 상태를 나타내는 변수

  @override
  void initState() {
    super.initState();
    // 텍스트 필드 포커스 상태 변경 시 UI 업데이트
    _textFieldFocusNode.addListener(() {
      setState(() {
        _isFocused = _textFieldFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _textFieldFocusNode.dispose(); // 포커스 노드 해제
    _postController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  // 여러 장의 사진을 갤러리에서 선택하는 함수
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage(
      imageQuality: 80, // 이미지 품질 조정
    );

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        // 최대 10장까지만 선택할 수 있도록 제한
        final remainingSlots = 10 - _selectedImages.length;
        final filesToAdd = pickedFiles
            .take(remainingSlots)
            .map((file) => File(file.path))
            .toList();
        _selectedImages.addAll(filesToAdd);
      });
    }
  }

  // 사진의 순서를 변경하는 함수
  void _onReorder(int oldIndex, int newIndex) {
    if (_selectedImages.length > 1) {
      setState(() {
        if (newIndex > oldIndex) newIndex -= 1;
        final File movedImage = _selectedImages.removeAt(oldIndex);
        _selectedImages.insert(newIndex, movedImage);
      });
    }
  }

  // 선택된 사진을 표시하는 위젯
  Widget _buildReorderableImage(int index) {
    return Stack(
      key: ValueKey(_selectedImages[index]),
      children: [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _selectedImages[index],
              width: 120,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedImages.removeAt(index); // 사진 삭제
              });
            },
            child: Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // 게시글을 업로드하는 함수
  Future<void> _uploadPost() async {
    if (_postController.text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("내용 또는 이미지를 추가하세요!")));
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // ✅ Firebase Storage에 이미지 업로드 후 다운로드 URL 가져오기
      List<String> imageUrls = [];
      for (File image in _selectedImages) {
        try {
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          Reference storageRef =
              FirebaseStorage.instance.ref().child("posts/$fileName.jpg");

          UploadTask uploadTask = storageRef.putFile(image);

          // ❗ 예외 처리 추가 (업로드 진행 상황 확인)
          TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
          String downloadUrl = await snapshot.ref.getDownloadURL();

          imageUrls.add(downloadUrl);
        } catch (e) {
          print("❌ 이미지 업로드 실패: $e");
        }
      }

      // ✅ Firestore에 게시물 저장 (이미지 하나라도 업로드 성공한 경우)
      if (imageUrls.isNotEmpty || _postController.text.isNotEmpty) {
        await Provider.of<PostProvider>(context, listen: false).uploadPost(
            postContent: _postController.text, postImages: imageUrls);

        // 업로드 성공 후 이전 화면으로 이동
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("업로드할 이미지나 내용이 없습니다.")));
      }
    } catch (e) {
      print("❌ 게시물 업로드 오류: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("업로드 실패!")));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _customListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius:
          BorderRadius.vertical(top: Radius.circular(20)), // 상단 모서리 둥글게
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
          ),
          //title: Text('피드작성'), // 화면 제목
          actions: [
            TextButton(
              onPressed: () {}, // 임시 저장 로직
              child: Text('임시 저장', style: TextStyle(color: Color(0xFF477BFF))),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImages, // 사진 선택 버튼
                        child: Container(
                          width: 120,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color(0xfff1f1f1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('사진 추가',
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 200,
                          child: _selectedImages.length > 1
                              ? ReorderableListView(
                                  scrollDirection: Axis.horizontal,
                                  onReorder: _onReorder,
                                  proxyDecorator: (child, index, animation) {
                                    return Material(
                                      elevation: 4.0, // 드래그된 항목에 그림자 효과 추가
                                      color: Colors.transparent,
                                      child: Transform.scale(
                                        scale: 1.05, // 드래그된 항목이 살짝 커짐
                                        child: child,
                                      ),
                                    );
                                  },
                                  children: [
                                    for (int index = 0;
                                        index < _selectedImages.length;
                                        index++)
                                      _buildReorderableImage(index),
                                  ],
                                )
                              : ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    for (int index = 0;
                                        index < _selectedImages.length;
                                        index++)
                                      _buildReorderableImage(index),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 150, // 텍스트 필드 높이
                    child: TextField(
                      focusNode: _textFieldFocusNode, // 텍스트 필드 포커스
                      controller: _postController,
                      cursorColor: Color(0xFF477BFF),
                      maxLength: 500, // 최대 500자 제한
                      decoration: InputDecoration(
                        hintText: '문구를 작성해주세요.',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                  SizedBox(height: 16),
                  _customListTile(
                    icon: Icons.person,
                    title: '사람 태그',
                    onTap: () {}, // 사람 태그 선택
                  ),
                  _customListTile(
                    icon: Icons.location_on,
                    title: '위치 태그',
                    onTap: () {}, // 위치 태그 선택
                  ),
                  _customListTile(
                    icon: Icons.public,
                    title: '공개 대상',
                    onTap: () {}, // 공개 대상 선택
                  ),
                  _customListTile(
                    icon: Icons.translate,
                    title: '번역',
                    onTap: () {}, // 번역 선택
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            _isUploading ? null : _uploadPost, // 공유 버튼 로직
                        child: _isUploading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                '공유',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF477BFF),
                            //padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isFocused)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus(); // 텍스트 필드 포커스 해제
                  },
                  child: Container(
                    color: Colors.transparent, // 배경 처리 없음
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
