import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/BasicInfoScreen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class PhoneVerificationScreen extends StatefulWidget {
  //final String phoneNumber;
  final String verificationId;
  final int currentStep; // 현재 회원가입 단계

  PhoneVerificationScreen({
    //required this.phoneNumber,
    required this.verificationId,
    this.currentStep = 6,
  });

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  late int _timeRemaining;
  late bool _isResendEnabled;
  bool _isTimerRunning = true;
  bool _isButtonEnabled = false;
  bool _isLoading = false;
  final TextEditingController _pinController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _timeRemaining = 180;
    _isResendEnabled = false;
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_timeRemaining > 0 && _isTimerRunning) {
        setState(() {
          _timeRemaining--;
        });
        _startTimer();
      } else if (_timeRemaining == 0 && _isTimerRunning) {
        setState(() {
          _isResendEnabled = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    String smsCode = _pinController.text;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: smsCode,
    );

    try {
      // 현재 로그인된 사용자 (이메일 인증을 통해 로그인됨)
      User? user = _auth.currentUser;

      if (user != null) {
        // 전화번호 인증 후 기존 계정에 연결
        await user.linkWithCredential(credential);

        // 🔹 Firestore의 step을 7로 업데이트
        await FirebaseFirestore.instance
            .collection('pending_users')
            .doc(user.uid)
            .update({
          'step': 7, // 전화번호 인증 완료 후 step 7로 변경
          'phoneVerifiedAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("전화번호 인증 성공!")),
        );

        // 인증 성공 시 BasicInfoScreen으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BasicInfoScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("전화번호 인증 실패: ${e.toString()}")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    String phoneNumber = signUpProvider.data.phoneNumber;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressBar(progress: widget.currentStep / 10),
            Text(
              "휴대전화 번호 인증",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "$phoneNumber 로 인증번호가 전송되었습니다.\n수신된 인증번호를 입력해주세요.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            SizedBox(height: 40),
            Center(
              child: Pinput(
                controller: _pinController,
                length: 6,
                showCursor: true,
                onChanged: (value) {
                  setState(() {
                    _isButtonEnabled = value.length == 6;
                  });
                },
                onCompleted: (value) {
                  setState(() {
                    _isButtonEnabled = true;
                  });
                },
              ),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Icon(Icons.timer, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      _formatTime(_timeRemaining),
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _isResendEnabled
                      ? () {
                          setState(() {
                            _timeRemaining = 180;
                            _isResendEnabled = false;
                            _startTimer();
                          });
                        }
                      : null,
                  child: Text(
                    "다시 보내기",
                    style: TextStyle(
                      color: _isResendEnabled ? Color(0xFF477BFF) : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled ? _verifyOTP : null,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          '확인',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonEnabled ? Color(0xFF477BFF) : Colors.grey,
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
