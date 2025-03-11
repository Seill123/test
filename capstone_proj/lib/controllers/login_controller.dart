import 'package:capstone_proj/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    String email = idController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, "이메일과 비밀번호를 입력해주세요.");
      return;
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await user.reload(); // ✅ 사용자 인증 정보 갱신
        user = _auth.currentUser; // ✅ 갱신된 정보 반영

        if (!user!.emailVerified) {
          _showErrorDialog(context, "이메일 인증을 완료해주세요.");
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      }
    } catch (e) {
      _showErrorDialog(context, "로그인 실패: ${e.toString()}");
    }
  }

  void loginWithGoogle() {
    // Google 로그인 로직 추가 예정
  }

  void loginWithApple() {
    // Apple 로그인 로직 추가 예정
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("오류"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }
}
