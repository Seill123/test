import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_proj/screens/onboarding/welcome_screen.dart';
//import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 설정 초기화
  );

  // Firebase Auth Emulator 연결 설정
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(MyApp()); // 앱 실행
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 상태바 텍스트 색상(검정)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // 상태바 배경 투명
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
      //home: PhoneSignUpScreen(),
      theme: ThemeData(fontFamily: 'Pretendard'),
      themeMode: ThemeMode.system, // 스플래시 후 WelcomeScreen으로 이동
    );
  }
}
