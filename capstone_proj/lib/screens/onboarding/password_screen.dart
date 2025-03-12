import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/email_verification_Screen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/screens/onboarding/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class PasswordScreen extends StatefulWidget {
  //final String email;
  final int currentStep; // 현재 회원가입 단계

  const PasswordScreen({Key? key, this.currentStep = 3}) : super(key: key);

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

  bool _isLoading = false;

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

  // 🔹 이메일 인증 링크 전송
  void _sendEmailVerification() async {
    setState(() {
      _isLoading = true; // 로딩 상태 시작
    });

    try {
      final signUpProvider =
          Provider.of<SignUpProvider>(context, listen: false);
      signUpProvider.updateUserData(password: passwordController.text);

      String email = signUpProvider.data.email; // Provider에서 이메일 가져오기
      String password = signUpProvider.data.password;

      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        // 🔹 Firestore에 step=4 저장 (pending_users 컬렉션)
        await FirebaseFirestore.instance
            .collection('pending_users')
            .doc(user.uid)
            .set({
          'email': email,
          'step': 4, // 현재 단계: 이메일 인증
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 🔹 이메일 인증 링크 전송
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }
      }

      // 🔹 현재 위젯이 아직 활성화된 상태(mounted)인지 확인 후 화면 전환
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EmailVerificationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이메일 인증 링크 전송 실패: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 로딩 상태 종료
        });
      }
    }
  }

  Widget _buildConditionRow(String text, bool conditionMet) {
    return Row(
      mainAxisSize: MainAxisSize.min, // 최소 크기로 설정
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.cancel,
          color: conditionMet ? Colors.green : Colors.red,
          size: 16,
        ),
        SizedBox(width: 4), // 아이콘과 텍스트 간격 축소
        Text(
          text,
          style: TextStyle(
              color: conditionMet ? Colors.green : Colors.red, fontSize: 12),
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
            ProgressBar(progress: widget.currentStep / 10),
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
                helperText:
                    isTyping ? null : '영문 대소문자, 숫자, 특수문자 포함 8자리 이상 입력해주세요.',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: _buildConditionRow("대소문자", hasUpperCase),
                  ),
                  SizedBox(width: 8), // 아이템 간격 축소
                  Flexible(
                    child: _buildConditionRow("숫자", hasNumber),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: _buildConditionRow("특수문자", hasSpecialChar),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: _buildConditionRow("8자 이상", hasMinLength),
                  ),
                ],
              ),
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
                      ? _sendEmailVerification
                      : null,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '다음',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
