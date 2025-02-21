import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'email_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isEmailEntered = false;
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    String email = _emailController.text;
    bool isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\$')
        .hasMatch(email);

    setState(() {
      _isEmailEntered = email.isNotEmpty;
      _isEmailValid = isValid || email.isEmpty;
    });
  }

  void _sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.sendSignInLinkToEmail(
        email: _emailController.text,
        actionCodeSettings: ActionCodeSettings(
          url: "https://capstoneproj.page.link",
          handleCodeInApp: true,
          androidPackageName: "com.example.capstone_proj",
          androidInstallApp: true,
          androidMinimumVersion: "21",
          iOSBundleId: "com.example.capstoneProj",
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("인증 이메일을 보냈어요! 이메일을 확인해주세요.")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EmailVerificationScreen(email: _emailController.text),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이메일 전송 실패: \${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _isEmailEntered && _isEmailValid;

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "로그인에 사용할 \n이메일을 알려주세요.",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              cursorColor: Color(0xFF477BFF),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '이메일',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: '이메일을 입력해주세요.',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
                errorText: _isEmailValid ? null : "이메일 형식에 맞게 작성해 주세요.",
                errorStyle: TextStyle(color: Colors.red),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isButtonEnabled ? _sendVerificationEmail : null,
                  child: Text(
                    '이메일 인증하기',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isButtonEnabled ? Color(0xFF477BFF) : Colors.grey,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
