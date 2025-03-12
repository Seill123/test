import 'package:capstone_proj/screens/main_screen.dart';
import 'package:capstone_proj/screens/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_proj/screens/SignupInProgressScreen.dart';
import 'package:flutter/cupertino.dart';

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isChecking = true; // 로딩 상태 추가
  User? _user;
  bool _isSignupIncomplete = false; // 🔹 회원가입 진행 여부 체크

  @override
  void initState() {
    super.initState();
    _checkAuthState(); // 로그인 상태 확인
  }

  void _checkAuthState() async {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      bool signupIncomplete = false;

      if (user != null) {
        var doc = await FirebaseFirestore.instance
            .collection('pending_users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          signupIncomplete = true; // 🔹 진행 중인 회원가입이 있음
        }
      }

      if (mounted) {
        setState(() {
          _user = user;
          _isSignupIncomplete = signupIncomplete;
          _isChecking = false;
        });

        // 🔹 회원가입이 완료되지 않은 경우 알림창 표시
        if (_isSignupIncomplete) {
          _showIncompleteSignupDialog();
        }
      }
    });
  }

  // 🔹 회원가입 미완료 알림창
  void _showIncompleteSignupDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: false, // 사용자가 강제로 닫지 못하게 설정
        builder: (context) => CupertinoAlertDialog(
          title: Text("회원가입 진행 중"),
          content: Text("아직 완료되지 않은 회원가입 있습니다.\n이어서 진행하시겠습니까?"),
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
                  style: TextStyle(
                      color: CupertinoColors.destructiveRed)), // iOS 스타일 적용
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return WelcomeScreen();
    } else if (_isSignupIncomplete) {
      return WelcomeScreen(); // 🔹 먼저 WelcomeScreen을 보여주고, 알림창에서 선택 후 이동
    } else {
      return MainScreen();
    }
  }
}
