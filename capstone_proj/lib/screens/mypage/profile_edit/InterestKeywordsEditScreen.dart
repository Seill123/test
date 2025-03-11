import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InterestKeywordsEditScreen extends StatefulWidget {
  @override
  _InterestKeywordsEditScreenState createState() =>
      _InterestKeywordsEditScreenState();
}

class _InterestKeywordsEditScreenState
    extends State<InterestKeywordsEditScreen> {
  List<String> selectedKeywords = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    fetchUserKeywords();
  }

  Future<void> fetchUserKeywords() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final List<String> keywords =
          List<String>.from(doc.data()?['interest_keywords'] ?? []);
      setState(() {
        selectedKeywords = keywords;
      });
    }
  }

  void toggleKeyword(String keyword) {
    setState(() {
      if (selectedKeywords.contains(keyword)) {
        selectedKeywords.remove(keyword);
      } else {
        if (selectedKeywords.length >= 5) {
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

  Future<void> saveKeywords() async {
    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'interest_keywords': selectedKeywords});
        Navigator.pop(context, selectedKeywords); // 결과 반환
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("키워드 저장 중 오류가 발생했습니다.")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget buildKeywordSection(String title, List<String> keywords) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
              selectedColor: Color(0xFFD5E7FF),
              backgroundColor: Colors.grey[200],
              side: BorderSide(
                color: isSelected ? Color(0xFF477BFF) : Colors.transparent,
                width: 2,
              ),
              labelStyle: TextStyle(
                color: isSelected ? Color(0xFF477BFF) : Color(0xFF7A7A7A),
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
        title: Text("관심 키워드",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: isSaving ? null : saveKeywords,
            child: Text(
              "완료",
              style: TextStyle(
                color: isSaving ? Colors.grey : Color(0xFF477BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("관심사를 골라볼까요?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("비슷한 관심사를 가진 친구를 추천해드릴게요!",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}
