import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserIdEditScreen extends StatefulWidget {
  @override
  _UserIdEditScreenState createState() => _UserIdEditScreenState();
}

class _UserIdEditScreenState extends State<UserIdEditScreen> {
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
        _nameController.text = userDoc['user_id'] ?? "";
      });
    }
  }

  Future<bool> _isUserIdAvailable(String newUserId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('user_id', isEqualTo: newUserId)
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<void> _updateUserId(String newUserId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    WriteBatch batch = firestore.batch();

    try {
      DocumentReference userRef = firestore.collection('users').doc(user.uid);
      batch.update(userRef, {'user_id': newUserId});

      QuerySnapshot postSnapshot = await firestore
          .collection('Post')
          .where('uid', isEqualTo: user.uid)
          .get();
      for (var doc in postSnapshot.docs) {
        batch.update(doc.reference, {'user_id': newUserId});
      }

      QuerySnapshot commentSnapshot = await firestore
          .collection('Post_Comments')
          .where('uid', isEqualTo: user.uid)
          .get();
      for (var doc in commentSnapshot.docs) {
        batch.update(doc.reference, {'user_id': newUserId});
      }

      QuerySnapshot likesSnapshot = await firestore
          .collection('Post_Likes')
          .where('uid', isEqualTo: user.uid)
          .get();
      for (var doc in likesSnapshot.docs) {
        batch.update(doc.reference, {'user_id': newUserId});
      }

      await batch.commit();
      print("모든 user_id 업데이트 완료!");
    } catch (e) {
      print("user_id 업데이트 중 오류 발생: $e");
    }
  }

  Future<void> _saveUserName() async {
    String newUserId = _nameController.text.trim();
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사용자이름을 입력해주세요.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      bool isAvailable = await _isUserIdAvailable(newUserId);
      if (!isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("이미 사용 중인 사용자 입니다. 다른 이름을 입력해주세요.")),
        );
        return;
      }

      await _updateUserId(newUserId);
      Navigator.pop(context, newUserId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("사용자이름 저장 중 오류 발생")),
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
        title: Text('사용자이름',
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
              '사용자이름',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "사용자이름을 입력하세요",
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
