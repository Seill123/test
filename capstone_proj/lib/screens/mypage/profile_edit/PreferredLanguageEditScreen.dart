import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreferredLanguageEditScreen extends StatefulWidget {
  final String currentPreferredLanguage;

  PreferredLanguageEditScreen({required this.currentPreferredLanguage});

  @override
  _PreferredLanguageEditScreenState createState() =>
      _PreferredLanguageEditScreenState();
}

class _PreferredLanguageEditScreenState
    extends State<PreferredLanguageEditScreen> {
  List<Map<String, String>> allLanguages = [];
  List<Map<String, String>> filteredLanguages = [];
  String selectedLanguage = "";
  bool _isSaving = false;
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.currentPreferredLanguage;
    loadLanguages();
  }

  Future<void> loadLanguages() async {
    String jsonString = await rootBundle.loadString('assets/languages.json');
    List<dynamic> jsonResponse = json.decode(jsonString);
    List<Map<String, String>> languages =
        jsonResponse.map((data) => Map<String, String>.from(data)).toList();

    setState(() {
      allLanguages = languages;
      filteredLanguages = languages;
    });
  }

  Future<void> _savePreferredLanguage() async {
    if (selectedLanguage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("관심 언어를 선택해주세요.")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'preferred_language': selectedLanguage});

        Navigator.pop(context, selectedLanguage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("관심 언어 저장 중 오류 발생")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
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
        title: Text('관심 언어',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.grey[100],
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferredLanguage,
            child: Text(
              '완료',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Color(0xFF477BFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("관심 있는 언어를 \n선택해주세요",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("관심있는 언어를 친구들에게 알려주세요.",
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            // 검색창
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    filteredLanguages = allLanguages
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
                    borderSide: BorderSide(color: Color(0xFF477BFF), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            // 언어 리스트
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  String languageEn = filteredLanguages[index]["en"]!;
                  String languageNative = filteredLanguages[index]["native"]!;
                  bool isSelected = selectedLanguage == languageNative;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLanguage = languageNative;
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
                            Icon(Icons.check,
                                color: Color(0xFF477BFF), size: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
