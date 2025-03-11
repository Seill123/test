import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:capstone_proj/screens/onboarding/profile_screen.dart';
import 'package:capstone_proj/screens/onboarding/registration_complete_screen.dart';
import 'package:capstone_proj/widgets/ProgressBar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class KeywordSelectionScreen extends StatefulWidget {
  final int currentStep; // 현재 회원가입 단계
  KeywordSelectionScreen({this.currentStep = 10});

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
              selectedColor: Color(0xFFD5E7FF), // 선택된 배경색
              backgroundColor: Colors.grey[200], // 기본 배경색
              side: BorderSide(
                color: isSelected
                    ? Color(0xFF477BFF)
                    : Colors.transparent, // 선택된 경우 테두리 적용
                width: 2,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Color(0xFF477BFF)
                    : Color(0xFF7A7A7A), // 선택된 경우 텍스트 색상 변경
                fontWeight: FontWeight.bold,
              ),
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressBar(progress: widget.currentStep / 10),

            // 🔥 스크롤되지 않는 부분
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

            // 🔥 스크롤이 필요한 부분만 Expanded + ListView 사용
            Expanded(
              child: ListView(
                children: [
                  buildKeywordSection("💗 취미", hobbies),
                  SizedBox(height: 30),
                  buildKeywordSection("🍕 음식", foods),
                  SizedBox(height: 30),
                  buildKeywordSection("⚽ 스포츠/운동", sports),
                  SizedBox(height: 40),
                ],
              ),
            ),

            // 완료 버튼 (스크롤되지 않음)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    signUpProvider.updateUserData(
                        interestKeywords: selectedKeywords);
                    print("선택된 키워드: $selectedKeywords");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationCompleteScreen()),
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
