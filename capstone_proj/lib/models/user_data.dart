import 'package:flutter/foundation.dart';

class UserData with ChangeNotifier {
  String email = ''; // 이메일
  String password = ''; // 비밀번호 (원본, Firebase Auth용)
  String phoneNumber = ''; // 전화번호
  String location = ''; // 국적
  String nativeLanguage = ''; // 모국어
  String preferredLanguage = ''; // 관심 언어
  String profilePicture = ''; // 프로필 사진
  String userName = ''; // 사용자 이름
  String userId = ''; // 사용자 닉네임
  String birthdate = ''; // 생년월일
  String gender = ''; // 성별
  List<String> interestKeywords = []; // 관심 키워드 최대 5개

  // 데이터를 업데이트할 때 notifyListeners() 호출
  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value; // Firebase Auth에서 사용될 비밀번호
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    phoneNumber = value;
    notifyListeners();
  }

  void setLocation(String value) {
    location = value;
    notifyListeners();
  }

  void setNativeLanguage(String value) {
    nativeLanguage = value;
    notifyListeners();
  }

  void setPreferredLanguage(String value) {
    preferredLanguage = value;
    notifyListeners();
  }

  void setProfilePicture(String value) {
    profilePicture = value;
    notifyListeners();
  }

  void setUserName(String value) {
    userName = value;
    notifyListeners();
  }

  void setUserId(String value) {
    userId = value;
    notifyListeners();
  }

  void setBirthdate(String value) {
    birthdate = value;
    notifyListeners();
  }

  void setGender(String value) {
    gender = value;
    notifyListeners();
  }

  void setInterestKeywords(List<String> values) {
    interestKeywords = values.take(5).toList(); // 최대 5개 제한
    notifyListeners();
  }
}
