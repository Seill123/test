import 'package:flutter/material.dart';
import 'package:capstone_proj/controllers/login_controller.dart';

class LoginScreen extends StatelessWidget {
  final LoginController _controller = LoginController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); //뒤로가기
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
            Text(
              '로그인',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
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
            // 로그인 버튼
            SizedBox(
              width: double.infinity, // 버튼 너비를 화면 가득 채우기
              height: 48, //버튼 높이
              child: ElevatedButton(
                onPressed: () {
                  _controller.login(context);
                },
                child: Text(
                  '로그인',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    print('아이디 찾기');
                  },
                  child: Text('아이디 찾기'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print('비밀번호 찾기');
                  },
                  child: Text('비밀번호 찾기'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    '간편 로그인',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _controller.loginWithGoogle();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          backgroundImage: AssetImage('assets/google_logo.png'),
                        ),
                      ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          _controller.loginWithApple();
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 20,
                          backgroundImage: AssetImage('assets/apple_logo.png'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
