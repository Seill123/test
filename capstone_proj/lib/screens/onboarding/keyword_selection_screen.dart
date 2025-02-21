import 'package:capstone_proj/screens/onboarding/registration_complete_screen.dart';
import 'package:flutter/material.dart';

class KeywordSelectionScreen extends StatefulWidget {
  final String email;
  final String password;

  KeywordSelectionScreen({required this.email, required this.password});

  @override
  _KeywordSelectionScreenState createState() => _KeywordSelectionScreenState();
}

class _KeywordSelectionScreenState extends State<KeywordSelectionScreen> {
  List<String> selectedKeywords = []; // 선택된 키워드 리스트

  void toggleKeyword(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        if (selectedKeywords.length >= 5) {
          // 🔥 5개 이상 선택 방지 & 스낵바 띄우기
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("최대 5개까지 선택할 수 있습니다."),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        selectedKeywords.add(keyword);
      }
    });
  }

  Widget buildKeywordSection(String title, List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: keywords.map((keyword) {
            final isSelected = selectedKeywords.contains(keyword);
            return ChoiceChip(
              label: Text(keyword),
              selected: isSelected,
              onSelected: (_) => toggleKeyword(keyword),
              selectedColor: Color(0xFF477BFF),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF7A7A7A),
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 예시 키워드 데이터
    final List<String> hobbies = [
      '뷰티',
      '패션',
      '드라마',
      '영화',
      '헬스/건강',
      '재테크',
      '드로잉',
      '여행',
      '뮤지컬',
      '사진',
      '전시',
      '음악'
    ];
    final List<String> foods = [
      '한식',
      '양식',
      '라면',
      '파스타',
      '크로와상',
      '햄버거',
      '디저트',
      '일식',
      '밀크티',
      '중식',
      '와인',
      '맥주',
      '카페'
    ];
    final List<String> sports = [
      '축구',
      '농구',
      '배드민턴',
      'MMA',
      'EPL',
      'NBA',
      '요가',
      '주짓수',
      '태권도',
      '필라테스',
      '요가',
      '서핑',
      '골프',
      '테니스'
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              // ListView를 감싸서 전체 화면을 차지하도록 함
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "관심있는 키워드를\n설정해주세요.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "관심있는 키워드를 선택하면\n관심사가 비슷한 친구를 추천해줍니다.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),

                  // 각 섹션 렌더링
                  buildKeywordSection("💗 취미", hobbies),
                  SizedBox(height: 30), // 섹션 간 간격
                  buildKeywordSection("🍕 음식", foods),
                  SizedBox(height: 30), // 섹션 간 간격
                  buildKeywordSection("⚽ 스포츠/운동", sports),

                  SizedBox(height: 40),
                ],
              ),
            ),

            // 완료 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    print("선택된 키워드: $selectedKeywords");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationCompleteScreen(
                                email: widget.email,
                                password: widget.password,
                              )),
                    );
                  },
                  child: Text(
                    "다음",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF477BFF),
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
