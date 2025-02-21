import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  PhoneVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
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
  String _enteredOTP = "";
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
      await _auth.signInWithCredential(credential);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("인증 성공!")),
      );
      // TODO: 로그인 후 다음 화면으로 이동
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("인증 실패: ${e.toString()}")),
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
            Text(
              "휴대전화 번호 인증",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "${widget.phoneNumber} 로 인증번호가 전송되었습니다.\n수신된 인증번호를 입력해주세요.",
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
                    _enteredOTP = value;
                    _isButtonEnabled = value.length == 6;
                  });
                },
                onCompleted: (value) {
                  setState(() {
                    _enteredOTP = value;
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
