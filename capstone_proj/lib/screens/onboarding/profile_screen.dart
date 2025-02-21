import 'package:capstone_proj/screens/onboarding/nationality_screen.dart';
import 'package:capstone_proj/screens/onboarding/password_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

class ProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  ProfileScreen({required this.email, required this.password});
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _birthDateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  String _selectedGender = '';
  DateTime? _selectedDate;
  String _name = '';
  String _username = '';
  bool _isUsernameValid = false; // 기본값: false

  // 버튼 활성화 여부를 결정하는 함수
  bool get _isFormValid {
    return _name.isNotEmpty &&
        _selectedGender.isNotEmpty &&
        _selectedDate != null &&
        _username.isNotEmpty &&
        _isUsernameValid; // 🔹 사용자 이름이 유효해야 활성화됨
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  void _showDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext builder) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            height: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🔹 **상단에 Cancel(취소) & Done(완료) 버튼 배치**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // 여기에 선택한 날짜를 저장하는 로직 추가 가능
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF477BFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Divider(height: 1),
                SizedBox(
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _selectedDate ?? DateTime(2000, 1, 1),
                    maximumDate: DateTime.now(),
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    onDateTimeChanged: (DateTime newDate) {
                      setState(() {
                        _selectedDate = newDate;
                        _birthDateController.text =
                            "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
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
  }

  void _validateUsername() {
    String message;
    Color backgroundColor;
    bool isValid = false; // 검사 결과를 저장할 변수

    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(_username)) {
      message = "사용자 이름에는 문자, 숫자, 밑줄 및 마침표만 사용할 수 있습니다.";
      backgroundColor = Colors.red;
    } else {
      message = "사용 가능한 사용자 이름입니다.";
      backgroundColor = Colors.green;
      isValid = true; // 유효한 경우 true로 변경
    }

    setState(() {
      _isUsernameValid = isValid; // 상태 업데이트
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PasswordScreen(email: "사용자의 이메일"), // 이메일 전달!
              ),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('프로필 설정',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        backgroundColor: Color(0xFF477BFF),
                        radius: 16,
                        child: Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            TextField(
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
                setState(() {
                  _name = value;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
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
                suffixIcon: IconButton(
                  icon: Icon(Icons.check_circle, color: Color(0xFF477BFF)),
                  onPressed: _validateUsername, // 클릭 시 유효성 검사 실행
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _username = value;
                });
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
                hintText: 'YYYY-MM-DD',
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF477BFF))),
              ),
              onTap: () => _showDatePicker(context),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGender = '여성';
                    });
                  },
                  child: Text('여성',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender == '여성'
                        ? Color(0xFF477BFF)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    fixedSize: Size(98, 35),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedGender = '남성';
                    });
                  },
                  child: Text('남성',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedGender == '남성'
                        ? Color(0xFF477BFF)
                        : Colors.grey[300],
                    foregroundColor: Colors.white,
                    fixedSize: Size(98, 35),
                  ),
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
                  onPressed: _isFormValid
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NationalitySelectionScreen(
                                      email: widget.email,
                                      password: widget.password,
                                    )),
                          );
                        }
                      : null,
                  child: Text('다음',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormValid ? Color(0xFF477BFF) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
