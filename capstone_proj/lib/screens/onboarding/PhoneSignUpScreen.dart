import 'package:capstone_proj/screens/onboarding/PhoneVerificationScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhoneSignUpScreen extends StatefulWidget {
  @override
  _PhoneSignUpScreenState createState() => _PhoneSignUpScreenState();
}

class _PhoneSignUpScreenState extends State<PhoneSignUpScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPhoneEntered = false;
  bool _isPhoneValid = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    String phone = _phoneController.text;
    bool isValid = RegExp(r'^(?:\+?82)?0[0-9]{9,10}$').hasMatch(phone);

    setState(() {
      _isPhoneEntered = phone.isNotEmpty;
      _isPhoneValid = isValid || phone.isEmpty;
    });
  }

  Future<void> _sendOTP() async {
    if (!_isPhoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("올바른 전화번호 형식을 입력해주세요.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String phoneNumber = "+82${_phoneController.text.substring(1)}"; // 국제번호 변환

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60), // 타임아웃 설정 (60초)
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("자동 인증 완료: ${credential.verificationId}");
        },
        verificationFailed: (FirebaseAuthException e) {
          print("인증 실패: ${e.message}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("인증번호 전송 실패: ${e.message}")),
          );
          setState(() {
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          print("인증번호 전송 완료. Verification ID: $verificationId");

          if (verificationId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("인증 ID를 받을 수 없습니다. 다시 시도해주세요.")),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          setState(() {
            _isLoading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneVerificationScreen(
                phoneNumber: _phoneController.text,
                verificationId: verificationId,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("자동 인증 시간 초과: $verificationId");
        },
      );
    } catch (e) {
      print("OTP 전송 중 오류 발생: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP 전송 중 오류 발생: $e")),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _isPhoneEntered && _isPhoneValid && !_isLoading;

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
              "휴대전화 번호를 인증해주세요.",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "휴대전화 번호는 본인 인증을 위해서만 사용됩니다.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              cursorColor: Color(0xFF477BFF),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: '전화번호',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'ex)01012345678',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
                errorText: _isPhoneValid ? null : "전화번호 형식에 맞게 작성해 주세요.",
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
                  onPressed: isButtonEnabled ? _sendOTP : null,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '인증번호 받기',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
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
