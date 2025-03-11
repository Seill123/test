import 'package:capstone_proj/providers/post_provider.dart';
import 'package:capstone_proj/screens/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/welcome_screen.dart';
import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 엔진 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase 설정 초기화
  );

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

    return MultiProvider(
      // MultiProvider로 감싸기
      providers: [
        ChangeNotifierProvider(
            create: (context) => SignUpProvider()), // SignUpProvider 등록
        ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Pretendard'),
        themeMode: ThemeMode.system, // 스플래시 후 WelcomeScreen으로 이동
        home: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(), // 키보드 숨기기
          child: AuthCheck(),
        ),

        // Firebase 딥 링크(route) 처리
        onGenerateRoute: (settings) {
          Uri uri = Uri.parse(settings.name ?? '');

          if (uri.path == '/link') {
            return MaterialPageRoute(
              builder: (context) => PhoneSignUpScreen(),
            );
          }

          return null; // 다른 라우트는 기본 처리
        },
      ),
    );
  }
}

// 로그인 상태를 확인하는 위젯
class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isChecking = true; // 로딩 상태 추가
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkAuthState(); // 로그인 상태 확인
  }

  void _checkAuthState() async {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _user = user;
          _isChecking = false; // 로딩 완료
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return Center(child: CircularProgressIndicator()); // 🔹 초기 로딩 화면
    }
    return _user != null
        ? MainScreen()
        : WelcomeScreen(); // 🔹 로그인 여부에 따라 화면 전환
  }
}
