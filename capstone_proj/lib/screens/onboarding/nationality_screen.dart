import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';

class NationalitySelectionScreen extends StatefulWidget {
  @override
  _NationalitySelectionScreenState createState() =>
      _NationalitySelectionScreenState();
}

class _NationalitySelectionScreenState
    extends State<NationalitySelectionScreen> {
  List<Map<String, String>> allCountries = [];
  List<Map<String, String>> filteredCountries = [];
  String selectedCountry = "";
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadCountries();
    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    selectedCountry = signUpProvider.data.location;
  }

  Future<void> _loadCountries() async {
    String jsonString = await rootBundle.loadString('assets/countries.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    setState(() {
      allCountries =
          jsonResponse.map((item) => Map<String, String>.from(item)).toList();
      filteredCountries = allCountries;
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
      body: allCountries.isEmpty
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중 표시
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("국적을 선택해주세요.",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text("이후 변경할 수 없으니 정확히 선택해주세요.",
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                                  country["en"]!
                                      .toLowerCase()
                                      .contains(value.toLowerCase()) ||
                                  country["ko"]!.contains(value))
                              .toList();
                        });
                      },
                      cursorColor: Color(0xFF477BFF),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "국적 검색",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Color(0xFF477BFF), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Colors.grey, width: 1.0),
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
                        String flag = filteredCountries[index]["flag"]!;
                        String countryEn = filteredCountries[index]["en"]!;
                        String countryKo = filteredCountries[index]["ko"]!;
                        bool isSelected = selectedCountry == countryKo;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCountry = countryKo;
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF477BFF)
                                    : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 4,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      flag,
                                      style: TextStyle(fontSize: 24),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      countryEn,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
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
                    padding:
                        const EdgeInsets.only(bottom: 40, left: 16, right: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: selectedCountry.isEmpty
                            ? null
                            : () {
                                print("선택된 국적: $selectedCountry");
                                Provider.of<SignUpProvider>(context,
                                        listen: false)
                                    .updateUserData(location: selectedCountry);
                                Navigator.pop(context, selectedCountry);
                              },
                        child: Text(
                          '완료',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedCountry.isEmpty
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
