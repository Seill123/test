import 'package:capstone_proj/screens/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/controllers/login_controller.dart';
import 'package:capstone_proj/screens/SignupInProgressScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatelessWidget {
  final LoginController _controller = LoginController();

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

    // 🔹 진행 중인 회원가입이 없으면 로그인 진행
    _controller.login(context);
  }

  // 🔹 회원가입 진행 중이면 경고창 표시
  void _showIncompleteSignupDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
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
                  await FirebaseFirestore.instance
                      .collection('pending_users')
                      .doc(uid)
                      .delete();

                  await user.delete();
                } catch (e) {
                  print("회원가입 취소 중 오류 발생: $e");
                }
              }

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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('로그인',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 32),
            TextField(
              controller: _controller.idController,
              cursorColor: Color(0xFF477BFF),
              decoration: InputDecoration(
                labelText: '아이디',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: '아이디를 입력해주세요.',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 8),
            TextField(
              controller: _controller.passwordController,
              cursorColor: Color(0xFF477BFF),
              decoration: InputDecoration(
                labelText: '비밀번호',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: '비밀번호를 입력해주세요.',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () =>
                    _checkSignupProgress(context), // 🔹 로그인 시 회원가입 진행 여부 확인
                child: Text('로그인',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF477BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => print('아이디 찾기'),
                  child: Text('아이디 찾기'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
                TextButton(
                  onPressed: () => print('비밀번호 찾기'),
                  child: Text('비밀번호 찾기'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text('간편 로그인',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => _controller.loginWithGoogle(),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          backgroundImage: AssetImage('assets/google_logo.png'),
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _controller.loginWithApple(),
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20,
                          backgroundImage: AssetImage('assets/apple_logo.png'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
