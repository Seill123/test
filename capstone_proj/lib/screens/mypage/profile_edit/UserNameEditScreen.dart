import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNameEditScreen extends StatefulWidget {
  @override
  _UserNameEditScreenState createState() => _UserNameEditScreenState();
}

class _UserNameEditScreenState extends State<UserNameEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['user_name'] ?? "";
      });
    }
  }

  Future<void> _saveUserName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이름을 입력해주세요.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'user_name': _nameController.text.trim()});
      }

      // 변경된 이름을 반환하며 화면 닫기
      Navigator.pop(context, _nameController.text.trim());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("이름 저장 중 오류 발생")),
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
        title: Text('이름',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveUserName,
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
              '이름',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "이름을 입력하세요",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF477BFF), width: 2),
                ),
              ),
              style: TextStyle(fontSize: 18),
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
