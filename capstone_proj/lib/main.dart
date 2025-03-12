import 'package:capstone_proj/AuthCheck.dart';
import 'package:capstone_proj/providers/post_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';
import 'package:capstone_proj/controllers/search_controller.dart' as AppSearch;

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
        ChangeNotifierProvider(
            create: (context) => AppSearch.SearchController()),
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
