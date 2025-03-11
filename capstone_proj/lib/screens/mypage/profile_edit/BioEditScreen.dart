import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BioEditScreen extends StatefulWidget {
  @override
  _BioEditScreenState createState() => _BioEditScreenState();
}

class _BioEditScreenState extends State<BioEditScreen> {
  final TextEditingController _bioController = TextEditingController();
  bool _isSaving = false;
  int _remainingChars = 150;
  bool _isSnackBarVisible = false; // 스낵바 중복 방지

  @override
  void initState() {
    super.initState();
    _loadUserBio();
    _bioController.addListener(_updateRemainingChars);
  }

  @override
  void dispose() {
    _bioController.removeListener(_updateRemainingChars);
    _bioController.dispose();
    super.dispose();
  }

  void _updateRemainingChars() {
    if (_bioController.text.length > 150) {
      _bioController.text = _bioController.text.substring(0, 150);
      _bioController.selection = TextSelection.fromPosition(
          TextPosition(offset: _bioController.text.length));

      // 이미 스낵바가 떠 있지 않을 때만 실행
      if (!_isSnackBarVisible) {
        _isSnackBarVisible = true;
        ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 기존 스낵바 숨기기
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text("소개는 최대 150자까지 입력 가능합니다."),
                duration: Duration(seconds: 2),
              ),
            )
            .closed
            .then((_) {
          _isSnackBarVisible = false; // 스낵바 닫히면 다시 false로 변경
        });
      }
    }

    setState(() {
      _remainingChars = 150 - _bioController.text.length;
    });
  }

  Future<void> _loadUserBio() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userProfileDoc = await FirebaseFirestore.instance
        .collection('user_profile')
        .doc(user.uid)
        .get();

    if (userProfileDoc.exists) {
      setState(() {
        _bioController.text = userProfileDoc['bio'] ?? "";
        _remainingChars = 150 - _bioController.text.length;
      });
    }
  }

  Future<void> _saveUserBio() async {
    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_profile')
            .doc(user.uid)
            .update({'bio': _bioController.text.trim()});
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar(); // 뒤로 가기 전 스낵바 숨기기
      Navigator.pop(context, _bioController.text.trim()); // ✅ 수정된 bio 값을 반환
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("소개 저장 중 오류 발생")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('소개',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveUserBio,
            child: Text(
              '완료',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Color(0xFF477BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '소개',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                hintText: "자신을 소개해주세요",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF), width: 2),
                ),
              ),
              maxLines: 5,
              style: TextStyle(fontSize: 18),
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_remainingChars',
                style: TextStyle(
                  fontSize: 14,
                  color: _remainingChars < 0 ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
