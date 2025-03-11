import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/screens/onboarding/welcome_screen.dart'; // 로그아웃 후 이동할 화면

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle("설정"),
          _buildSection([
            _buildMenuItem(text: '계정 설정', icon: Icons.person),
            _buildMenuItem(text: '알림', icon: Icons.notifications),
            _buildMenuItem(text: '1:1 문의', icon: Icons.error),
          ]),
          _buildSectionTitle("이용약관"),
          _buildSection([
            _buildMenuItem(text: '개인정보 처리방침', icon: Icons.lock_outline),
            _buildMenuItem(text: '서비스 이용약관', icon: Icons.article_outlined),
          ]),
          _buildSection([
            _buildMenuItem(
              text: '로그아웃',
              icon: Icons.exit_to_app,
              onTap: () => _logout(context), // 로그아웃 기능 추가
            ),
            _buildMenuItem(
              text: '탈퇴하기',
              icon: Icons.delete_forever,
              iconColor: Color(0xFFFE2D56),
              textColor: Color(0xFFFE2D56),
            ),
          ]),
        ],
      ),
    );
  }

  /// 🔹 로그아웃 함수
  void _logout(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.signOut(); // 🔹 로그아웃 실행

      await Future.delayed(Duration(milliseconds: 500)); // 🔹 Firebase 상태 반영 대기

      // Firebase 인증 상태가 변경될 때까지 기다림
      await FirebaseAuth.instance.authStateChanges().first;

      if (!context.mounted) return; // 🔹 UI가 여전히 활성화된 상태인지 확인

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => WelcomeScreen()), // 🔹 로그인 화면으로 이동
        (route) => false, // 🔹 모든 이전 화면 제거
      );
    } catch (e) {
      print("로그아웃 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그아웃에 실패했습니다. 다시 시도해주세요.")),
      );
    }
  }

  /// 🔹 섹션 제목
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  /// 🔹 섹션 (아이템 리스트)
  Widget _buildSection(List<Widget> items) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items
              .expand((item) => [
                    item,
                    Divider(height: 1, thickness: 1, color: Colors.grey[300])
                  ])
              .toList()
            ..removeLast(),
        ],
      ),
    );
  }

  /// 🔹 메뉴 아이템 빌드 함수
  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    Color iconColor = Colors.black,
    Color textColor = Colors.black,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(text, style: TextStyle(color: textColor)),
      onTap: onTap ?? () => print('$text 클릭됨'),
    );
  }
}
