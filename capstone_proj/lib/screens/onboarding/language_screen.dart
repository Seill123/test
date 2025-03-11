import 'package:capstone_proj/providers/sign_up_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  List<Map<String, String>> allLanguage = [];
  List<Map<String, String>> filteredLanguage = [];
  String selectedLanguage = "";
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadJsonData();

    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    selectedLanguage = signUpProvider.data.nativeLanguage;
  }

  Future<void> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/languages.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    List<Map<String, String>> languages =
        jsonResponse.map((data) => Map<String, String>.from(data)).toList();

    setState(() {
      allLanguage = languages;
      filteredLanguage = languages;
    });
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 텍스트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "모국어를 선택해주세요.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "이후 변경할 수 없으니 정확히 선택해주세요.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),

            // 검색 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    filteredLanguage = allLanguage
                        .where((lang) =>
                            lang["en"]!
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            lang["native"]!.contains(value))
                        .toList();
                  });
                },
                cursorColor: Color(0xFF477BFF),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "언어 검색",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Color(0xFF477BFF),
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            // 언어 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguage.length,
                itemBuilder: (context, index) {
                  String languageEn = filteredLanguage[index]["en"]!;
                  String languagenative = filteredLanguage[index]["native"]!;
                  bool isSelected = selectedLanguage == languagenative;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = languagenative;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Color(0xFF477BFF) : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languageEn, // 영어 표시
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Color(0xFF477BFF)
                                      : Colors.black,
                                ),
                              ),
                              Text(
                                languagenative, // 한국어 표시
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check,
                              color: Color(0xFF477BFF),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 완료 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedLanguage.isEmpty
                      ? null
                      : () {
                          print("선택된 모국어: $selectedLanguage");
                          Provider.of<SignUpProvider>(context, listen: false)
                              .updateUserData(nativeLanguage: selectedLanguage);
                          Navigator.pop(context, selectedLanguage);
                        },
                  child: Text(
                    '완료',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedLanguage.isEmpty
                        ? Colors.grey
                        : Color(0xFF477BFF),
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
