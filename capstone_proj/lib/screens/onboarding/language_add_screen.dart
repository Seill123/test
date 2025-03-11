import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/providers/sign_up_provider.dart';

class LanguageAddScreen extends StatefulWidget {
  @override
  _LanguageAddScreenState createState() => _LanguageAddScreenState();
}

class _LanguageAddScreenState extends State<LanguageAddScreen> {
  List<Map<String, String>> allLanguage = [];
  List<Map<String, String>> filteredLanguage = [];
  String selectedInterestLanguages = "";
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadJsonData();

    final signUpProvider = Provider.of<SignUpProvider>(context, listen: false);
    selectedInterestLanguages = signUpProvider.data.preferredLanguage;
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "관심 있는 언어를 \n선택해주세요",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "관심있는 언어를 친구들에게 알려주세요.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
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
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguage.length,
                itemBuilder: (context, index) {
                  String languageEn = filteredLanguage[index]["en"]!;
                  String languageNative = filteredLanguage[index]["native"]!;
                  bool isSelected = selectedInterestLanguages == languageNative;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedInterestLanguages = languageNative;
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
                                languageEn,
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
                                languageNative,
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
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 16, right: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: selectedInterestLanguages.isEmpty
                      ? null
                      : () {
                          print("관심 언어: $selectedInterestLanguages");
                          Provider.of<SignUpProvider>(context, listen: false)
                              .updateUserData(
                                  preferredLanguage: selectedInterestLanguages);
                          Navigator.pop(context, selectedInterestLanguages);
                        },
                  child: Text(
                    '추가',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedInterestLanguages.isEmpty
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
