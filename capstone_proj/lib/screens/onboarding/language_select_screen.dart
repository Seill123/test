import 'package:capstone_proj/screens/onboarding/keyword_selection_screen.dart';
import 'package:capstone_proj/screens/onboarding/language_add_screen.dart';
import 'package:flutter/material.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final String email;
  final String password;

  LanguageSelectionScreen({required this.email, required this.password});

  @override
  _LanguageSelectionScreenState createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  List<String> selectedLanguages = []; // 선택된 언어 리스트

  void navigateToAddLanguage() async {
    // LanguageAddScreen으로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LanguageAddScreen(
          initialSelectedLanguages: selectedLanguages,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        selectedLanguages = result; // 선택된 언어 리스트 업데이트
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Text(
              "관심 있는 언어를\n선택해주세요.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "관심있는 언어를 친구들에게 알려주세요.\n최대 5개 선택",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),

            // 언어 추가 버튼
            GestureDetector(
              onTap: navigateToAddLanguage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                child: Row(
                  children: [
                    // 동그라미 안에 add 아이콘 추가
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF477BFF), // 동그라미 배경색
                        shape: BoxShape.circle, // 원 모양
                      ),
                      padding: EdgeInsets.all(2), // 아이콘 크기 조정
                      child: Icon(
                        Icons.add,
                        color: Colors.white, // 아이콘 색상
                        size: 20, // 아이콘 크기
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "언어 추가하기",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // 선택된 언어 리스트
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: selectedLanguages.map((language) {
                return Chip(
                  label: Text(
                    language,
                    style: TextStyle(
                        color: Color(0xFF7A7A7A),
                        fontWeight: FontWeight.bold), // 텍스트 색상을 흰색으로 변경
                  ),
                  backgroundColor: Color(0xFFFFFFFF), // 배경색 적용
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Color(0xFF477BFF)), // 테두리 색상 적용
                    borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                  ),
                  onDeleted: () {
                    setState(() {
                      selectedLanguages.remove(language);
                    });
                  },
                  deleteIconColor: Color(0xFF477BFF),
                );
              }).toList(),
            ),

            Spacer(),

            // 다음 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedLanguages.isNotEmpty
                      ? () {
                          // 다음 화면으로 이동
                          print("선택된 언어: $selectedLanguages");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KeywordSelectionScreen(
                                      email: widget.email,
                                      password: widget.password,
                                    )),
                          );
                        }
                      : null, // 비활성화
                  child: Text(
                    "다음",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedLanguages.isNotEmpty
                        ? Color(0xFF477BFF) // 활성화 색상
                        : Colors.grey, // 비활성화 색상
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
