import 'package:capstone_proj/screens/onboarding/TermsAgreementScreen.dart';
import 'package:capstone_proj/screens/onboarding/login_screen.dart';
import 'package:capstone_proj/screens/SignupInProgressScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  Future<void> _checkSignupProgress(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      var doc = await FirebaseFirestore.instance
          .collection('pending_users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        _showIncompleteSignupDialog(context);
        return;
      }
    }

    // 🔹 진행 중인 회원가입이 없으면 TermsAgreementScreen으로 이동
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => TermsAgreementScreen()),
    );
  }

  // 🔹 회원가입 진행 중인 경우 알림창 띄우기
  void _showIncompleteSignupDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false, // 강제 종료 방지
      builder: (context) => CupertinoAlertDialog(
        title: Text("회원가입 진행 중"),
        content: Text("아직 완료되지 않은 회원가입이 있습니다.\n이어서 진행하시겠습니까?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;

              if (user != null) {
                String uid = user.uid;

                try {
                  // Firestore에서 pending_users 문서 삭제
                  await FirebaseFirestore.instance
                      .collection('pending_users')
                      .doc(uid)
                      .delete();

                  // Firebase Authentication 계정 삭제
                  await user.delete();
                } catch (e) {
                  print("회원가입 취소 중 오류 발생: $e");
                }
              }

              // 로그아웃 후 WelcomeScreen으로 이동
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
            child: Text("취소",
                style: TextStyle(color: CupertinoColors.destructiveRed)),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                    builder: (context) => SignupInProgressScreen()),
              );
            },
            child: Text("확인", style: TextStyle(color: Color(0xFF477BFF))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Image.asset(
                'assets/main_logo.png',
                height: 100,
              ),
              SizedBox(height: 28),
              Text(
                "TapTalk+에 오신 것을 환영합니다!",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "전 세계와 연결되는 새로운 경험을 시작하세요.",
                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 220),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: Image.asset('assets/google_logo.png', height: 24),
                  label: Text("Google로 시작하기",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // 구글 로그인 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: Image.asset('assets/apple_logo.png', height: 28),
                  label: Text("Apple로 시작하기",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // 애플 로그인 로직
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 28),
              Text("또는", style: TextStyle(color: Colors.grey)),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () =>
                      _checkSignupProgress(context), // 🔹 버튼 클릭 시 진행 중인지 확인
                  child: Text("계정 만들기",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF477BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text.rich(
                TextSpan(
                  text: "이미 계정이 있으신가요? ",
                  style: TextStyle(color: Colors.grey),
                  children: [
                    TextSpan(
                      text: "로그인",
                      style: TextStyle(color: Color(0xFF477BFF)),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
