//UI 다시 할 예정


/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_proj/screens/onboarding/password_screen.dart'; 

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  const EmailVerificationScreen({Key? key, required this.email})
      : super(key: key);

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _checkEmailVerified();
  }

  // 이메일 인증 여부 확인
  Future<void> _checkEmailVerified() async {
    setState(() {
      _isChecking = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload(); // 사용자 정보 새로고침

    if (user != null && user.emailVerified) {
      setState(() {
        _isVerified = true;
      });

      // 인증 완료되면 다음 화면(비밀번호 입력)으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(email: widget.email),
        ),
      );
    }

    setState(() {
      _isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("이메일 인증"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "이메일을 확인해주세요.",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("인증 링크를 보냈어요. 이메일(${widget.email})을 확인하고 인증을 완료해주세요."),
            SizedBox(height: 20),
            _isChecking
                ? Center(child: CircularProgressIndicator())
                : _isVerified
                    ? Text(
                        "이메일 인증이 완료되었습니다!",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      )
                    : Text(
                        "이메일 인증을 완료한 후, '확인' 버튼을 눌러주세요.",
                        style: TextStyle(color: Colors.red),
                      ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}*/



