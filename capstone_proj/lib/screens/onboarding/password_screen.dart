import 'package:flutter/material.dart';
import 'package:capstone_proj/screens/onboarding/profile_screen.dart';
import 'package:capstone_proj/screens/onboarding/signup_screen.dart';

class PasswordScreen extends StatefulWidget {
  final String email; // 이메일을 받을 변수 추가

  // 생성자 수정 (super.key 추가)
  PasswordScreen({Key? key, required this.email}) : super(key: key);

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isPasswordMatched = false;
  bool isTyping = false; // 사용자가 입력 중인지 확인하는 변수

  bool hasUpperCase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;

  void _validatePassword(String password) {
    setState(() {
      isTyping = password.isNotEmpty; // 입력 중이면 조건 표시
      hasUpperCase = RegExp(r'[A-Z]').hasMatch(password);
      hasNumber = RegExp(r'[0-9]').hasMatch(password);
      hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
      hasMinLength = password.length >= 8;
      _validatePasswordMatch();
    });
  }

  void _validatePasswordMatch() {
    setState(() {
      isPasswordMatched = passwordController.text.isNotEmpty &&
          passwordController.text == confirmPasswordController.text;
    });
  }

  Widget _buildConditionRow(String text, bool conditionMet) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.cancel,
          color: conditionMet ? Colors.green : Colors.red,
          size: 18,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              color: conditionMet ? Colors.green : Colors.red, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignUpScreen()),
            );
          },
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '비밀번호 설정',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 32),

            // 비밀번호 입력 필드
            Text('비밀번호',
                style: TextStyle(fontSize: 16, color: Color(0xFF477BFF))),
            TextField(
              controller: passwordController,
              cursorColor: Color(0xFF477BFF),
              obscureText: !isPasswordVisible,
              onChanged: _validatePassword,
              decoration: InputDecoration(
                hintText: '비밀번호 입력',
                helperText: isTyping
                    ? null
                    : '영문 대소문자, 숫자, 특수문자 포함 8자리 이상 입력해주세요.', // 입력 전에는 기본 안내 메시지
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF477BFF))),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),

            // 입력 시작하면 조건 체크 리스트 표시
            if (isTyping) ...[
              _buildConditionRow("대문자 포함", hasUpperCase),
              _buildConditionRow("숫자 포함", hasNumber),
              _buildConditionRow("특수문자 포함", hasSpecialChar),
              _buildConditionRow("8자 이상 입력", hasMinLength),
            ],

            SizedBox(height: 24),

            // 비밀번호 확인 필드
            Text('비밀번호 확인',
                style: TextStyle(fontSize: 16, color: Color(0xFF477BFF))),
            TextField(
              controller: confirmPasswordController,
              cursorColor: Color(0xFF477BFF),
              obscureText: !isConfirmPasswordVisible,
              onChanged: (value) => _validatePasswordMatch(),
              decoration: InputDecoration(
                hintText: '비밀번호 확인',
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF477BFF))),
                suffixIcon: IconButton(
                  icon: Icon(
                    isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8),

            // 비밀번호 일치 여부 메시지
            if (confirmPasswordController.text.isNotEmpty)
              Row(
                children: [
                  Icon(
                    isPasswordMatched ? Icons.check_circle : Icons.cancel,
                    color: isPasswordMatched ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    isPasswordMatched ? '비밀번호가 일치합니다.' : '비밀번호가 일치하지 않습니다.',
                    style: TextStyle(
                      color: isPasswordMatched ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

            Spacer(),

            // 다음 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (hasUpperCase &&
                          hasNumber &&
                          hasSpecialChar &&
                          hasMinLength &&
                          isPasswordMatched)
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileScreen(
                                    email: widget.email,
                                    password: passwordController.text)),
                          );
                        }
                      : null,
                  child: Text(
                    '다음',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (hasUpperCase &&
                            hasNumber &&
                            hasSpecialChar &&
                            hasMinLength &&
                            isPasswordMatched)
                        ? Color(0xFF477BFF)
                        : Colors.grey,
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
