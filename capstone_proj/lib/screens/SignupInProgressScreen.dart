import 'package:capstone_proj/screens/onboarding/BasicInfoScreen.dart';
import 'package:capstone_proj/screens/onboarding/PhoneSignUpScreen.dart';
import 'package:capstone_proj/screens/onboarding/TermsAgreementScreen.dart';
import 'package:capstone_proj/screens/onboarding/email_verification_Screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io'; // 🔹 앱 종료를 위해 추가

class SignupInProgressScreen extends StatefulWidget {
  @override
  _SignupInProgressScreenState createState() => _SignupInProgressScreenState();
}

class _SignupInProgressScreenState extends State<SignupInProgressScreen> {
  bool _isLoading = true;
  int _step = 1; // 🔹 기본적으로 1단계부터 시작

  @override
  void initState() {
    super.initState();
    _loadSignupStep(); // Firestore에서 진행 상태 불러오기
  }

  Future<void> _loadSignupStep() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    var doc = await FirebaseFirestore.instance
        .collection('pending_users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _step = doc.data()?['step'] ?? 1; // 🔹 Firestore에서 step 값 가져오기
        _isLoading = false;
      });

      // 🔹 회원가입 단계에 맞는 화면으로 이동
      _navigateToStep();
    }
  }

  void _navigateToStep() {
    Widget nextScreen;

    switch (_step) {
      case 4:
        nextScreen = EmailVerificationScreen();
        break;
      case 5:
        nextScreen = PhoneSignUpScreen();
        break;
      case 7:
        nextScreen = BasicInfoScreen();
        break;
      default:
        nextScreen = TermsAgreementScreen(); // 기본적으로 처음부터 시작
    }

    // 🔹 현재 화면을 없애고 다음 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => nextScreen));
    });
  }

  Future<bool> _onWillPop() async {
    return await showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("회원가입 진행 중"),
            content: Text("회원가입을 완료하지 않으면 데이터가 저장되지 않습니다.\n정말 종료하시겠습니까?"),
            actions: [
              CupertinoDialogAction(
                onPressed: () =>
                    Navigator.of(context).pop(false), // 아니요 → 다이얼로그 닫기
                child: Text("아니요",
                    style: TextStyle(color: CupertinoColors.activeBlue)),
              ),
              CupertinoDialogAction(
                onPressed: () => exit(0), // 네, 나갈래요 → 앱 종료
                isDestructiveAction: true, // 빨간색 강조
                child: Text("네, 나갈래요"),
              ),
            ],
          ),
        ) ??
        false; // 다이얼로그 닫히면 false 반환
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body:
            Center(child: CircularProgressIndicator()), // 🔹 Firestore 데이터 로딩 중
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop, // 🔹 뒤로 가기 버튼 감지
      child: Scaffold(
        body: Center(child: Text("이동 중...")), // 🔹 곧 다음 화면으로 이동
      ),
    );
  }
}
