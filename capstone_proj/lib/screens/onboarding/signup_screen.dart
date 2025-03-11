import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/screens/onboarding/password_screen.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';

class SignUpScreen extends StatefulWidget {
  final int currentStep; // 현재 회원가입 단계

  SignUpScreen({this.currentStep = 2});
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
    bool isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);

    setState(() {
      _isEmailEntered = email.isNotEmpty;
      _isEmailValid = isValid || email.isEmpty;
    });
  }

  /// 🔥 이메일 입력 후 PasswordScreen으로 이동
  void _goToPasswordScreen() {
    if (_isEmailEntered && _isEmailValid) {
      final signUpProvider =
          Provider.of<SignUpProvider>(context, listen: false);
      signUpProvider.updateUserData(email: _emailController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(),
        ),
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
            ProgressBar(progress: widget.currentStep / 10),
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
                  onPressed: isButtonEnabled ? _goToPasswordScreen : null,
                  child: Text(
                    '다음',
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
