import 'package:flutter/material.dart';

class LoginController {
  // 입력 필드 컨트롤러
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // 일반 로그인
  void login() {
    final id = idController.text.trim();
    final password = passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      print('아이디와 비밀번호를 입력해주세요!');
    } else {
      // TODO: 서버 요청 로직
      print('로그인 시도: 아이디 = $id, 비밀번호 = $password');
    }
  }

  //  구글 로그인
  void loginWithGoogle() {
    // TODO: 구글 로그인 기능 추가
    print('구글 로그인 시도');
  }

  // 애플 로그인
  void loginWithApple() {
    // TOdO: 애플 로그인 기능 추가
    print('애플 로그인 시도');
  }
}
