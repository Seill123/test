import 'package:flutter/material.dart';

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
          _buildSectionTitle("계정"),
          _buildSection([
            _buildMenuItem(text: '로그아웃', icon: Icons.exit_to_app),
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

  /// 🔹 섹션 제목 (텍스트만)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700]),
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
