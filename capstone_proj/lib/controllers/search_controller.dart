import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class SearchController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    _searchQuery = query;
    developer.log('검색어 설정: $_searchQuery', name: 'SearchController');
    notifyListeners();
  }

  // 사용자 검색 스트림
  Stream<QuerySnapshot> searchUsers() {
    developer.log('사용자 검색 실행: $_searchQuery', name: 'SearchController');

    // 검색어가 비어있거나 짧을 경우 모든 사용자 반환 (최대 20명)
    if (_searchQuery.isEmpty || _searchQuery.length < 2) {
      developer.log('검색어가 비어있거나 짧아서 모든 사용자 반환', name: 'SearchController');
      return _firestore
          .collection('users')
          .orderBy('user_name')
          .limit(20)
          .snapshots();
    }

    try {
      // user_name 필드를 사용하여 검색 (대소문자 구분)
      return _firestore
          .collection('users')
          .orderBy('user_name')
          .startAt([_searchQuery]).endAt([_searchQuery + '\uf8ff']).snapshots();
    } catch (e) {
      developer.log('사용자 검색 오류: $e', name: 'SearchController');

      // 오류 발생 시 모든 사용자 반환 (최대 20명)
      return _firestore.collection('users').limit(20).snapshots();
    }
  }

  // 게시물 검색 스트림
  Stream<QuerySnapshot> searchPosts() {
    developer.log('게시물 검색 실행: $_searchQuery', name: 'SearchController');

    // 검색어가 비어있거나 짧을 경우 최근 게시물 반환
    if (_searchQuery.isEmpty || _searchQuery.length < 2) {
      developer.log('검색어가 비어있거나 짧아서 최근 게시물 반환', name: 'SearchController');
      return _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots();
    }

    try {
      // 검색어를 소문자로 변환하여 keywords 배열에 포함된 게시물 검색
      return _firestore
          .collection('posts')
          .where('keywords', arrayContains: _searchQuery.toLowerCase())
          .snapshots();
    } catch (e) {
      developer.log('게시물 검색 오류: $e', name: 'SearchController');

      // 오류 발생 시 최근 게시물 반환
      return _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots();
    }
  }

  // 채팅방 생성 또는 기존 채팅방 찾기
  Future<String> createOrGetChatRoom(String otherUserId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null) {
        throw Exception('로그인이 필요합니다');
      }

      // 두 사용자 ID를 정렬하여 일관된 채팅방 ID 생성
      final List<String> userIds = [currentUserId, otherUserId];
      userIds.sort(); // 정렬하여 항상 동일한 순서 보장
      final String roomId = userIds.join('_');

      // 채팅방이 이미 존재하는지 확인
      final chatRoomDoc =
          await _firestore.collection('chatRooms').doc(roomId).get();

      if (!chatRoomDoc.exists) {
        // 채팅방이 없으면 새로 생성
        await _firestore.collection('chatRooms').doc(roomId).set({
          'userIds': userIds,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
          'isDeleted': false,
        });
      }

      _isLoading = false;
      notifyListeners();
      return roomId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = '채팅방 생성 중 오류가 발생했습니다: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // 현재 사용자 ID 가져오기
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _errorMessage = '사용자 정보를 가져오는 중 오류가 발생했습니다: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }
}
