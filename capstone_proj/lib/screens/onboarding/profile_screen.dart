import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/keyword_selection_screen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
//import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  final int currentStep; // 현재 회원가입 단계
  ProfileScreen({this.currentStep = 9});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 텍스트 컨트롤러: 생년월일, 사용자 ID, 사용자 이름 입력을 관리
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  //final ImagePicker _picker = ImagePicker(); // 이미지 선택을 위한 ImagePicker 인스턴스

  @override
  void initState() {
    super.initState();

    // initState 내에서 context를 직접 참조할 수 없으므로 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final signUpProvider =
          Provider.of<SignUpProvider>(context, listen: false);
      _userNameController.text = signUpProvider.data.userName;
      _userIdController.text = signUpProvider.data.userId;
      _birthDateController.text = signUpProvider.data.birthdate;
    });
  }

  // 📌 갤러리에서 이미지 선택 후 Firebase Storage에 업로드하는 함수
  Future<void> _pickImage(BuildContext context) async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    String downloadUrl = await _uploadImageToStorage(image);

    if (downloadUrl.isNotEmpty) {
      Provider.of<SignUpProvider>(context, listen: false)
          .updateUserData(profilePicture: downloadUrl);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("이미지 업로드에 실패했습니다.")));
    }
  }

// 📌 Firebase Storage에 이미지 업로드 함수
  Future<String> _uploadImageToStorage(XFile image) async {
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(
          'profile_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');

      File file = File(image.path); // 🔥 XFile을 File로 변환
      if (!await file.exists()) {
        throw Exception("파일이 존재하지 않습니다.");
      }

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("❌ 이미지 업로드 오류: $e");
      return "";
    }
  }

  // 생년월일 선택을 위한 DatePicker 표시
  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext builder) {
        return Consumer<SignUpProvider>(
          builder: (context, signUpProvider, child) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(16),
                height: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 취소 및 완료 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold)),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text("Done",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF477BFF),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(height: 1),
                    SizedBox(
                      height: 150,
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.date,
                        initialDateTime:
                            signUpProvider.data.birthdate.isNotEmpty
                                ? DateTime.parse(signUpProvider.data.birthdate)
                                : DateTime(2000, 1, 1),
                        maximumDate: DateTime.now(),
                        minimumYear: 1900,
                        maximumYear: DateTime.now().year,
                        onDateTimeChanged: (DateTime newDate) {
                          String formattedDate =
                              "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";

                          // Provider에 저장
                          signUpProvider.updateUserData(
                              birthdate: formattedDate);

                          // TextField에도 반영
                          setState(() {
                            _birthDateController.text = formattedDate;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpProvider>(
      builder: (context, signUpProvider, child) {
        bool isFormValid = signUpProvider.data.userName.isNotEmpty &&
            signUpProvider.data.userId.isNotEmpty &&
            signUpProvider.data.birthdate.isNotEmpty &&
            signUpProvider.data.gender.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressBar(progress: widget.currentStep / 10),
                Text('프로필 설정',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 24),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () => _pickImage(context),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: signUpProvider
                                  .data.profilePicture.isNotEmpty
                              ? (signUpProvider.data.profilePicture
                                      .startsWith("http") // ✅ URL인지 확인
                                  ? NetworkImage(
                                          signUpProvider.data.profilePicture)
                                      as ImageProvider
                                  : (File(signUpProvider.data.profilePicture)
                                          .existsSync() // ✅ 로컬 파일이 존재하는지 확인
                                      ? FileImage(File(signUpProvider.data
                                          .profilePicture)) as ImageProvider
                                      : null))
                              : null,
                          child: signUpProvider.data.profilePicture.isEmpty
                              ? Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickImage(context),
                          child: CircleAvatar(
                            backgroundColor: Color(0xFF477BFF),
                            radius: 16,
                            child: Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _userNameController,
                  cursorColor: Color(0xFF477BFF),
                  decoration: InputDecoration(
                    labelText: '성명',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF477BFF))),
                  ),
                  onChanged: (value) {
                    signUpProvider.updateUserData(userName: value);
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _userIdController,
                  cursorColor: Color(0xFF477BFF),
                  decoration: InputDecoration(
                    labelText: '사용자 이름',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF477BFF)),
                    ),
                    suffixIcon: Icon(
                      signUpProvider.data.userId.isNotEmpty &&
                              RegExp(r'^[a-zA-Z0-9_.]+$')
                                  .hasMatch(signUpProvider.data.userId)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: signUpProvider.data.userId.isNotEmpty &&
                              RegExp(r'^[a-zA-Z0-9_.]+$')
                                  .hasMatch(signUpProvider.data.userId)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  onChanged: (value) {
                    signUpProvider.updateUserData(userId: value);
                    setState(() {
                      _userIdController.text = value; // UI 업데이트
                    });

                    // 사용자 이름 유효성 검사
                    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(value)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("사용자 이름에는 문자, 숫자, 밑줄 및 마침표만 사용할 수 있습니다."),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _birthDateController,
                  cursorColor: Color(0xFF477BFF),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: '생년월일',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF477BFF)),
                    ),
                  ),
                  onTap: () => _showDatePicker(context),
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        signUpProvider.updateUserData(gender: '여성');
                      },
                      child: Text('여성',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: signUpProvider.data.gender == '여성'
                            ? Color(0xFF477BFF)
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        fixedSize: Size(98, 35),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        signUpProvider.updateUserData(gender: '남성');
                      },
                      child: Text('남성',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: signUpProvider.data.gender == '남성'
                              ? Color(0xFF477BFF)
                              : Colors.grey[300],
                          foregroundColor: Colors.white,
                          fixedSize: Size(98, 35)),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '나이와 성별은 수정이 불가하므로 진실된\n 개인정보를 제공하세요',
                      style: TextStyle(color: Color(0xFF477BFF), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isFormValid
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        KeywordSelectionScreen()),
                              );
                            }
                          : null,
                      child: Text('다음',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFormValid ? Color(0xFF477BFF) : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
