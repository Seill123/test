import 'package:capstone_proj/screens/mypage/profile_edit/BioEditScreen.dart';
import 'package:capstone_proj/screens/mypage/profile_edit/InterestKeywordsEditScreen.dart';
import 'package:capstone_proj/screens/mypage/profile_edit/PreferredLanguageEditScreen.dart';
import 'package:capstone_proj/screens/mypage/profile_edit/UserIdEditScreen.dart';
import 'package:capstone_proj/screens/mypage/profile_edit/UserNameEditScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  File? _image;
  String? _profileImageUrl;
  String name = "";
  String userName = "";
  String bio = "";
  String nationality = "";
  String gender = "";
  String interests = "";
  String email = "";
  String phone_number = "";
  String native_language = "";
  String preferred_language = "";
  String birthdate = "";

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // users 컬렉션에서 기본 정보 가져오기
    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(currentUser.uid).get();

    // user_profile 컬렉션에서 추가 정보 가져오기
    DocumentSnapshot userProfileDoc =
        await firestore.collection('user_profile').doc(currentUser.uid).get();

    if (userDoc.exists) {
      setState(() {
        name = userDoc['user_name'] ?? "";
        userName = userDoc['user_id'] ?? "";
        nationality = userDoc['location'] ?? "";
        gender = userDoc['gender'] ?? "";
        interests = (userDoc['interest_keywords'] as List?)?.join(", ") ?? "";
        email = userDoc['email'] ?? "";
        phone_number = userDoc['phone_number'] ?? "";
        _profileImageUrl = userDoc['profile_picture'] ?? "";
        native_language = userDoc['native_language'] ?? "";
        preferred_language = userDoc['preferred_language'] ?? "";
        birthdate = userDoc['birthdate'] ?? "";
      });
    }

    if (userProfileDoc.exists) {
      setState(() {
        bio = userProfileDoc['bio'] ?? "";
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFAFAFA),
      appBar: AppBar(
        title: Text('프로필 수정',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage: _image != null
                  ? FileImage(_image!) as ImageProvider
                  : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty
                      ? NetworkImage(_profileImageUrl!)
                      : null),
              child: (_image == null &&
                      (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: _pickImage,
              child: Text('사진 변경', style: TextStyle(color: Color(0xFF477BFF))),
            ),
            SizedBox(height: 16),
            _buildSection('사용자 정보', [
              _buildProfileItem(title: '이름', value: name),
              _buildProfileItem(title: '사용자 이름', value: '@$userName'),
              _buildProfileItem(
                  title: '소개', value: bio.isEmpty ? '+ 소개 작성' : bio),
              _buildProfileItem(
                  title: '국적', value: nationality, isEditable: false),
              _buildProfileItem(title: '성별', value: gender, isEditable: false),
            ]),
            _buildSection('언어', [
              _buildProfileItem(
                  title: '모국어', value: native_language, isEditable: false),
              _buildProfileItem(title: '관심 언어', value: preferred_language)
            ]),
            _buildSection('프로필 정보', [
              _buildProfileItem(title: '관심사', value: interests),
              _buildProfileItem(title: '이메일', value: email, isEditable: false),
              _buildProfileItem(
                  title: '전화번호', value: phone_number, isEditable: false),
              _buildProfileItem(
                  title: '생년월일', value: birthdate, isEditable: false),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileItem({
    required String title,
    required String value,
    bool isEditable = true,
  }) {
    return InkWell(
      onTap: isEditable ? () => _navigateToEditScreen(context, title) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text가 길어질 경우 자동 줄바꿈 + 말줄임표 적용
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    maxLines: 2, // 최대 2줄까지 허용
                    overflow: TextOverflow.ellipsis, // 너무 길면 "..." 처리
                  ),
                ),
                if (isEditable)
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, String field) async {
    Widget screen;

    switch (field) {
      case '이름':
        screen = UserNameEditScreen();
        break;
      case '사용자 이름':
        screen = UserIdEditScreen();
        break;
      case '소개':
        screen = BioEditScreen();
        break;
      case '관심 언어':
        screen = PreferredLanguageEditScreen(
          currentPreferredLanguage: preferred_language,
        );
        break;
      case '관심사':
        screen = InterestKeywordsEditScreen();
        break;
      default:
        return;
    }

    // 수정된 값 받아와서 업데이트
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    if (result != null) {
      // 🔥 수정 완료 후 Firestore에서 최신 데이터 다시 가져오기
      _loadUserProfile();
    }
  }
}
