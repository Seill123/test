import 'package:flutter/material.dart';

class LanguageAddScreen extends StatefulWidget {
  final List<String> initialSelectedLanguages;

  LanguageAddScreen({required this.initialSelectedLanguages});

  @override
  _LanguageAddScreenState createState() => _LanguageAddScreenState();
}

class _LanguageAddScreenState extends State<LanguageAddScreen> {
  List<String> frequentlyUsedLanguages = [
    '영어',
    '중국어',
    '한국어',
    '일본어',
    '프랑스어'
  ]; // 많이 쓰는 언어 리스트
  List<String> availableLanguages = [
    '영어',
    '중국어',
    '스페인어',
    '프랑스어',
    '일본어',
    '독일어',
    '러시아어',
    '한국어',
    '이탈리아어',
    '포르투갈어'
  ]; // 선택 가능한 언어 리스트
  List<String> filteredLanguages = []; // 검색 결과에 표시할 언어 리스트
  List<String> selectedLanguages = []; // 현재 선택된 언어 리스트
  Map<String, int> languageLevels = {}; // 언어 레벨
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedLanguages = List.from(widget.initialSelectedLanguages); // 초기 선택
    filteredLanguages = List.from(availableLanguages); // 초기 검색 리스트 설정
    for (var language in selectedLanguages) {
      languageLevels[language] = 1; // 기본 레벨 1로 설정
    }
  }

  void toggleLanguageSelection(String language) {
    setState(() {
      if (selectedLanguages.contains(language)) {
        selectedLanguages.remove(language);
        languageLevels.remove(language);
      } else {
        if (selectedLanguages.length < 5) {
          selectedLanguages.add(language);
          languageLevels[language] = 1; // 기본 레벨 1로 추가
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("최대 5개의 언어만 선택 가능합니다."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  void setLanguageLevel(String language, int level) {
    setState(() {
      languageLevels[language] = level;
    });
  }

  Widget buildLanguageSection(String title, List<String> languages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20, // 섹션 제목 텍스트 크기 20
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final isSelected = selectedLanguages.contains(language);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                  leading: Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Color(0xFF477BFF) : Colors.grey,
                    size: 28,
                  ),
                  title: Text(
                    language,
                    style: TextStyle(
                      fontSize: 16, // 각 언어 항목 텍스트 크기 16
                      color: isSelected ? Color(0xFF477BFF) : Colors.black,
                    ),
                  ),
                  onTap: () {
                    toggleLanguageSelection(language);
                  },
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0, bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (level) {
                        final levelIndex = level + 1;
                        return GestureDetector(
                          onTap: () {
                            setLanguageLevel(language, levelIndex);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: languageLevels[language] == levelIndex
                                  ? Color(0xFF477BFF)
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              'Lv.${levelIndex}',
                              style: TextStyle(
                                color: languageLevels[language] == levelIndex
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context, selectedLanguages); // 선택한 언어 반환
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "관심 언어 추가",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            // 검색창 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    filteredLanguages = availableLanguages
                        .where((language) => language
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList(); // 대소문자 구분 없이 검색
                  });
                },
                cursorColor: Color(0xFF477BFF), // 커서 색상 변경
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "언어 검색",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color(0xFF477BFF), // 포커스 시 테두리 색상 설정
                      width: 1.5, // 테두리 두께 설정
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.grey, // 기본 테두리 색상 설정
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildLanguageSection("많이 쓰는 언어", frequentlyUsedLanguages),
                    SizedBox(height: 20),
                    buildLanguageSection("모든 언어", filteredLanguages),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 40, right: 16, left: 16),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: selectedLanguages.isNotEmpty
                ? () {
                    Navigator.pop(context, selectedLanguages); // 선택한 언어 반환
                  }
                : null, // 비활성화
            child: Text(
              "적용하기(${selectedLanguages.length}/5)",
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
    );
  }
}
