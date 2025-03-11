import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userName;
  final String countryCode;

  ChatRoomScreen({required this.userName, required this.countryCode});

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _controller = TextEditingController();
  Color sendButtonColor = Colors.grey;

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.userName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "AM 01:34",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 32),
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildFlagIcon(widget.countryCode),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "@${widget.userName.toLowerCase()}",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "User_name",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            "English · 한국어",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Expanded(child: Container()),
          _messageInputField(), // ✅ 함수 대신 인스턴스 메서드 사용
        ],
      ),
    );
  }

  Widget _buildFlagIcon(String countryCode) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CountryFlag.fromCountryCode(
          countryCode,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  Widget _messageInputField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 28),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFF477BFF)),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (text) {
                setState(() {
                  sendButtonColor = text.isNotEmpty
                      ? Color(0xFF477BFF) // 입력 시 파란색
                      : Colors.grey; // 입력 없을 때 회색
                });
              },
              cursorColor: Color(0xFF477BFF),
              decoration: InputDecoration(
                hintText: "메시지를 입력하세요.",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.paperplane_fill, color: sendButtonColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
