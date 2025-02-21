import 'package:capstone_proj/screens/onboarding/language_screen.dart';
import 'package:capstone_proj/screens/onboarding/profile_screen.dart';
import 'package:flutter/material.dart';

class NationalitySelectionScreen extends StatefulWidget {
  final String email;
  final String password;

  NationalitySelectionScreen({required this.email, required this.password});
  @override
  _NationalitySelectionScreenState createState() =>
      _NationalitySelectionScreenState();
}

class _NationalitySelectionScreenState
    extends State<NationalitySelectionScreen> {
  // 전체 국가 리스트
  List<String> allCountries = [
    "대만",
    "대한민국",
    "덴마크",
    "동티모르",
    "도미니카",
    "도미니카 공화국",
    "독일",
    "디에고 가르시아",
    "라오스"
  ];

  // 검색 후 표시할 국가 리스트
  List<String> filteredCountries = [];
  String selectedCountry = "";

  // 검색 필드 포커스 관리
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 초기 상태에서는 모든 국가를 표시
    filteredCountries = allCountries;
  }

  @override
  void dispose() {
    // 포커스 노드 해제
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                        email: widget.email,
                        password: widget.password,
                      )),
            );
          },
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: GestureDetector(
        // 화면 다른 부분을 터치하면 포커스 해제
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "국적을 선택해주세요.",
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
            // 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    filteredCountries = allCountries
                        .where((country) =>
                            country.toLowerCase().contains(value.toLowerCase()))
                        .toList(); // 대소문자 구분 없이 검색
                  });
                },
                cursorColor: Color(0xFF477BFF), // 커서 색상 변경
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  hintText: "국적 검색",
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
            SizedBox(height: 12),
            // 국가 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filteredCountries.length,
                itemBuilder: (context, index) {
                  String country = filteredCountries[index];
                  return ListTile(
                    title: Text(
                      country,
                      style: TextStyle(
                        color: selectedCountry == country
                            ? Color(0xFF477BFF) // 선택된 경우 색상 변경
                            : Colors.black, // 기본 색상
                        fontWeight: selectedCountry == country
                            ? FontWeight.bold // 선택된 경우 볼드 처리
                            : FontWeight.normal,
                      ),
                    ),
                    leading: Transform.scale(
                      scale: 1.5, // 체크박스 크기 확대
                      child: Checkbox(
                        value: selectedCountry == country,
                        onChanged: (value) {
                          setState(() {
                            // 체크 시 선택, 다시 체크 해제 시 초기화
                            if (value == true) {
                              selectedCountry = country;
                            } else {
                              selectedCountry = "";
                            }
                          });
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        checkColor: Colors.white,
                        activeColor: Color(0xFF477BFF),
                        side: BorderSide(
                          color: Colors.grey, // 체크박스 테두리 회색으로 설정
                          width: 1.5,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                      ),
                    ),
                  );
                },
              ),
            ),
            // 다음 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52, // 버튼 크기 조금 확대
                child: ElevatedButton(
                  onPressed: selectedCountry.isEmpty
                      ? null
                      : () {
                          print("선택된 국적: $selectedCountry");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LanguageScreen(
                                email: widget.email,
                                password: widget.password,
                              ), // LanguageScreen으로 이동
                            ),
                          );
                        },
                  child: Text(
                    '다음',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedCountry.isEmpty
                        ? Colors.grey
                        : Color(0xFF477BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 둥근 버튼 모양
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
