import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:capstone_proj/models/user_data.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; //utf8 인코딩
import 'package:firebase_auth/firebase_auth.dart';

class SignUpProvider extends ChangeNotifier {
  final UserData userData = UserData(); // 사용자 데이터를 관리하는 모델
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스

  // UserData 객체를 외부에서 쉽게 접근할 수 있도록 하는 Getter
  UserData get data => userData;

  /// 사용자의 정보를 업데이트하는 메서드
  /// 각 필드는 선택적으로 업데이트 가능하며, 변경 사항이 있을 경우 notifyListeners()를 호출하여 UI 업데이트
  void updateUserData({
    String? email,
    String? password,
    String? phoneNumber,
    String? location,
    String? nativeLanguage,
    String? preferredLanguage,
    String? profilePicture,
    String? userName,
    String? userId,
    String? birthdate,
    String? gender,
    List<String>? interestKeywords,
  }) {
    if (email != null) userData.setEmail(email);
    if (password != null) userData.setPassword(password);
    if (phoneNumber != null) userData.setPhoneNumber(phoneNumber);
    if (location != null) userData.setLocation(location);
    if (nativeLanguage != null) userData.setNativeLanguage(nativeLanguage);
    if (preferredLanguage != null)
      userData.setPreferredLanguage(preferredLanguage);
    if (profilePicture != null) userData.setProfilePicture(profilePicture);
    if (userName != null) userData.setUserName(userName);
    if (userId != null) userData.setUserId(userId);
    if (birthdate != null) userData.setBirthdate(birthdate);
    if (gender != null) userData.setGender(gender);
    if (interestKeywords != null)
      userData.setInterestKeywords(interestKeywords);

    notifyListeners(); // 변경 사항이 있을 때 UI 업데이트
  }

  /// Firestore에 사용자 데이터를 저장하는 메서드
  /// 현재 인증된 Firebase 사용자의 UID를 기반으로 Firestore 문서를 생성
  Future<void> saveToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;
      // Firebase Auth에서 UID 가져오기
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        print("사용자 인증 정보가 없습니다.");
        return;
      }

      String UID = currentUser.uid; // Firebase UID 사용
      // 비밀번호를 SHA-256 해싱(Firestore에 저장용)
      String hashedPassword = _hashPassword(userData.password); // 비밀번호를 해싱하여 저장

      // Firestore의 'users' 컬렉션에 사용자 정보 저장
      await firestore.collection('users').doc(UID).set({
        'email': userData.email,
        'passwordHash': hashedPassword, // 원본 비밀번호 대신 해시 값 저장
        'phone_number': userData.phoneNumber,
        'location': userData.location,
        'native_language': userData.nativeLanguage,
        'preferred_language': userData.preferredLanguage,
        'profile_picture': userData.profilePicture,
        'user_name': userData.userName,
        'user_id': userData.userId,
        'birthdate': userData.birthdate,
        'gender': userData.gender,
        'interest_keywords': userData.interestKeywords,
        //'createdAt': FieldValue.serverTimestamp(), // 가입 시간 추가
      });

      // Firestore의 'user_profile' 컬렉션에도 추가 정보 저장 (소셜 기능용)
      await firestore.collection('user_profile').doc(UID).set({
        'bio': "", // 기본 프로필 소개 (초기값은 빈 문자열)
        'followers': [], // 팔로워 목록 (초기값 빈 배열)
        'following': [], // 팔로잉 목록 (초기값 빈 배열)
        'posts': [], // 사용자가 작성한 게시물 ID 리스트
      });

      print("Firestore 저장 완료");
    } catch (e) {
      print("Firestore 저장 오류: $e");
    }
  }

  /// 비밀번호를 SHA-256 알고리즘으로 해싱하는 메서드
  /// Firestore에 저장할 때 원본 비밀번호를 직접 저장하지 않고, 보안성을 높이기 위해 사용
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// 회원가입 완료 후 사용자 데이터를 초기화하는 메서드
  /// 보안을 위해 비밀번호는 Firebase Authentication에서만 사용하고 Firestore에 저장하지 않음
  void clearUserData() {
    userData.email = '';
    userData.password = ''; // Firestore에 저장하지 않고 Auth에서 관리
    userData.phoneNumber = '';
    userData.location = '';
    userData.nativeLanguage = '';
    userData.preferredLanguage = '';
    userData.profilePicture = '';
    userData.userName = '';
    userData.userId = '';
    userData.birthdate = '';
    userData.gender = '';
    userData.interestKeywords = [];

    notifyListeners(); // UI 업데이트
  }
}
