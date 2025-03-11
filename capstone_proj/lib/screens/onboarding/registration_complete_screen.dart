import 'package:capstone_proj/screens/main_screen.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  @override
  _RegistrationCompleteScreenState createState() =>
      _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState
    extends State<RegistrationCompleteScreen> {
  @override
  void initState() {
    super.initState();
    _registerUser();
  }

  Future<void> _registerUser() async {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);

    try {
      // Firestore에 저장
      await signUpProvider.saveToFirestore();

      // 데이터 저장 성공 후 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입이 완료되었습니다!")),
      );
    } catch (e) {
      print("회원가입 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입에 실패했습니다. 다시 시도해주세요.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 100,
                color: Color(0xFF477BFF),
              ),
              SizedBox(height: 20),
              Text(
                "회원가입이 완료되었습니다👏",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "TapTalk+에 가입해주셔서 감사합니다.\n다양한 기능을 탐색해보세요!",
                style: TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    "메인 화면으로 이동",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF477BFF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
