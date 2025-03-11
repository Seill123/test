import 'package:capstone_proj/screens/ChatRoomScreen.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "채팅",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF474747),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.person_add_alt, size: 28, color: Color(0xFF474747)),
            onPressed: () {
              print("친구 추가 클릭됨");
            },
          ),
          IconButton(
            icon: Icon(Icons.search, size: 28, color: Color(0xFF474747)),
            onPressed: () {
              print("검색 클릭됨");
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                size: 28, color: Color(0xFF474747)),
            onPressed: () {
              print("알림 클릭됨");
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 8),

          //  스토리 영역
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 5,
              itemBuilder: (context, index) => _buildStoryItem(index),
            ),
          ),

          // 채팅 목록
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => _buildChatItem(context, index),
            ),
          ),
        ],
      ),
    );
  }

  //스토리 아이템
  Widget _buildStoryItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              if (index == 0) // 나의 스토리는 플러스 버튼 추가
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF477BFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                )
              else // 일반 유저는 국기 추가
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildFlagIcon("US"), // 🇺🇸 예시 (ISO 코드)
                ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            index == 0 ? "나의 스토리" : "User_${index}",
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 채팅 리스트 아이템
  Widget _buildChatItem(BuildContext context, int index) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
          // 국가 플래그 추가
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildFlagIcon("KR"), // 🇰🇷 한국 예시
          ),
        ],
      ),
      title: Row(
        children: [
          Text(
            "User_${index + 1}",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text("Hello!!"),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("20:21"),
          SizedBox(height: 5),
          CircleAvatar(
            radius: 10,
            backgroundColor: Color(0xFF477BFF),
            child:
                Text("2", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
      onTap: () {
        // 클릭하면 해당 채팅방으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              userName: "User_${index + 1}",
              countryCode: "US",
            ),
          ),
        );
      },
    );
  }

  /// 🔹 국가 플래그 아이콘 빌드 함수
  Widget _buildFlagIcon(String countryCode) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게
        child: CountryFlag.fromCountryCode(
          countryCode,
          height: 18,
          width: 18,
        ),
      ),
    );
  }
}
