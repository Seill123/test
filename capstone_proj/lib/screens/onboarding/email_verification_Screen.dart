import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class EmailVerificationScreen extends StatefulWidget {
  //final String email;
  final int currentStep; // 현재 회원가입 단계

  const EmailVerificationScreen({Key? key, this.currentStep = 4})
      : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  // 🔹 이메일 인증 여부 확인
  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // 사용자 정보 새로고침
    setState(() {
      isEmailVerified = user?.emailVerified ?? false;
      _isLoading = false; // 로딩 종료
    });

    if (isEmailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhoneSignUpScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    String email = signUpProvider.data.email;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ProgressBar(progress: widget.currentStep / 10),
            SizedBox(height: 40),
            Icon(Icons.email_outlined, size: 80, color: Color(0xFF477BFF)),
            SizedBox(height: 16),

            // 이메일 안내 메시지를 카드 스타일로 변경
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "이메일 인증 요청됨",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "$email 로 전송된\n인증 링크를 확인해주세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            Text(
              "이메일이 오지 않았다면 스팸메일함을 확인하거나\n잠시 후 다시 시도해주세요.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),

            Spacer(),

            // 인증 완료 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkEmailVerification,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '이메일 인증 완료',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF477BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
