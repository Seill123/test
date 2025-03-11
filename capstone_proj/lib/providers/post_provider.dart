import 'package:capstone_proj/models/post_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore 인스턴스 생성
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase 인증 인스턴스 생성

  /// Firestore에서 게시물을 가져오는 메서드 (실시간 업데이트)
  /// 'postTime' 기준 내림차순 정렬하여 최신 게시물이 먼저 보이도록 설정
  Stream<List<PostModel>> getPosts() {
    return _firestore
        .collection('Post') // 'Post' 컬렉션에서 데이터 가져오기
        .orderBy('postTime', descending: true) // 최신순 정렬
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // 디버깅이 필요할 때만 로그 출력
        //debugPrint("🔥 Firestore에서 불러온 데이터: ${doc.data()}");
        return PostModel.fromJson(doc);
      }).toList();
    });
  }

  Stream<List<PostModel>> getUserPosts() {
    final String? currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      return Stream.value([]); // 로그인 정보가 없으면 빈 리스트 반환
    }

    return _firestore
        .collection('Post')
        .where('uid', isEqualTo: currentUserId) // 🔥 현재 사용자 UID로 필터링
        .orderBy('postTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PostModel.fromJson(doc)).toList();
    });
  }

  /// 새로고침을 위한 메서드 (UI 강제 업데이트)
  Future<void> fetchPosts() async {
    notifyListeners(); // UI 새로고침
  }

  /// Firestore에 새 게시물을 업로드하는 메서드
  /// 로그인한 사용자의 UID를 사용하여 게시물 저장
  Future<void> uploadPost({
    required String postContent, // 게시물 내용 (텍스트)
    required List<String> postImages, // 게시물 이미지 리스트
  }) async {
    try {
      // 현재 로그인한 사용자 확인
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("로그인된 사용자가 없습니다.");

      String uid = currentUser.uid; // 로그인한 사용자의 UID 가져오기
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get(); // 사용자 프로필 정보 가져오기

      if (!userDoc.exists) throw Exception("사용자 프로필 정보가 없습니다.");

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      DocumentReference newPostRef =
          _firestore.collection('Post').doc(); // 새 게시물 문서 참조 생성
      await newPostRef.set({
        'postId': newPostRef.id, // Firestore 문서 ID 저장
        'uid': uid, // 게시물 작성자 UID
        'user_id': userData['user_id'] ?? '익명', // 사용자 ID (없으면 '익명' 처리)
        'profileImageUrl': userData['profile_picture'] ?? '', // 프로필 이미지 URL
        'postContent': postContent, // 게시물 내용
        'postImages': postImages, // 게시물 이미지 리스트
        'postTime': FieldValue.serverTimestamp(), // 서버 시간 기준으로 작성 시간 저장
        'likeCount': 0, // 초기 좋아요 수 설정
        'commentCount': 0, // 초기 댓글 수 설정
        'likedProfiles': [], // 좋아요 누른 사용자 리스트 (빈 배열)
      });

      debugPrint("게시물 업로드 성공!");
    } catch (e) {
      debugPrint("게시물 업로드 오류: $e");
      throw e; // UI에서 에러 처리를 할 수 있도록 예외 던짐
    }
  }

  /// 🔥 게시물 삭제 함수
  Future<void> deletePost(String postId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("로그인이 필요합니다.");

      DocumentSnapshot postDoc =
          await _firestore.collection('Post').doc(postId).get();

      if (!postDoc.exists) throw Exception("해당 게시물이 존재하지 않습니다.");

      Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;

      if (postData['uid'] != currentUser.uid) {
        throw Exception("자신이 작성한 게시물만 삭제할 수 있습니다.");
      }

      WriteBatch batch = _firestore.batch();

      // 게시물 삭제
      batch.delete(_firestore.collection('Post').doc(postId));

      // 댓글 삭제
      QuerySnapshot comments = await _firestore
          .collection('Post_Comments')
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in comments.docs) {
        batch.delete(doc.reference);
      }

      // 좋아요 삭제
      QuerySnapshot likes = await _firestore
          .collection('Post_Likes')
          .where('postId', isEqualTo: postId)
          .get();

      for (var doc in likes.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit(); // 🔥 모든 삭제를 한 번에 실행

      debugPrint("게시물 및 관련 데이터 삭제 성공!");
    } catch (e) {
      debugPrint("게시물 삭제 중 오류 발생: $e");
      throw Exception("게시물 삭제 중 오류 발생: $e");
    }
  }

  /// 🔥 댓글 추가 기능
  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("로그인된 사용자가 없습니다.");

      String uid = currentUser.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) throw Exception("사용자 정보가 없습니다.");

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      DocumentReference newCommentRef =
          _firestore.collection('Post_Comments').doc();

      await newCommentRef.set({
        'comment_id': newCommentRef.id,
        'postId': postId,
        'uid': uid, // ✅ 고유 식별자로 변경
        'user_id': userData['user_id'] ?? '익명', // 🔥 닉네임 추가
        'profileImageUrl': userData['profile_picture'] ?? '', // 🔥 프로필 이미지 추가
        'content': content,
        'created_at': FieldValue.serverTimestamp(),
      });

      // 해당 게시물의 댓글 개수 증가
      await _firestore.collection('Post').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });

      debugPrint("댓글 추가 성공!");
    } catch (e) {
      debugPrint("댓글 추가 오류: $e");
      throw e;
    }
  }

  /// 🔥 특정 게시물의 댓글 가져오기 (실시간)
  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    return _firestore
        .collection('Post_Comments')
        .where('postId', isEqualTo: postId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> comments = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> commentData = doc.data();

        // 🔥 사용자 정보 가져오기
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(commentData['uid']).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          commentData['user_id'] = userData['user_id'] ?? '익명'; // 닉네임
          commentData['profileImageUrl'] =
              userData['profile_picture']; // 프로필 이미지
        } else {
          commentData['user_id'] = '알 수 없음';
          commentData['profileImageUrl'];
        }

        comments.add(commentData);
      }

      return comments;
    });
  }

  // 특정 게시물의 댓글 개수 가져오기
  Stream<int> getCommentsCount(String postId) {
    return _firestore
        .collection('Post_Comments') // 댓글 컬렉션
        .where('postId', isEqualTo: postId) // 해당 게시물의 댓글만 필터링
        .snapshots()
        .map((snapshot) => snapshot.docs.length); // 문서 개수를 가져옴 (댓글 개수)
  }

  Future<void> deleteComment(String commentId, String postId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("로그인이 필요합니다.");

      DocumentSnapshot commentDoc =
          await _firestore.collection('Post_Comments').doc(commentId).get();

      if (!commentDoc.exists) throw Exception("해당 댓글이 존재하지 않습니다.");

      Map<String, dynamic> commentData =
          commentDoc.data() as Map<String, dynamic>;

      if (commentData['uid'] != currentUser.uid) {
        throw Exception("자신이 작성한 댓글만 삭제할 수 있습니다.");
      }

      // 댓글 삭제
      await _firestore.collection('Post_Comments').doc(commentId).delete();

      // 해당 게시물의 댓글 수 감소
      await _firestore.collection('Post').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });

      debugPrint("댓글 삭제 성공!");
    } catch (e) {
      debugPrint("댓글 삭제 중 오류 발생: $e");
      throw Exception("댓글 삭제 중 오류 발생: $e");
    }
  }

  /// 🔥 좋아요 추가/삭제 기능
  Future<void> toggleLike(String postId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) throw Exception("로그인된 사용자가 없습니다.");

      String uid = currentUser.uid;
      DocumentReference likeRef =
          _firestore.collection('Post_Likes').doc('${postId}_$uid');
      DocumentReference postRef = _firestore.collection('Post').doc(postId);

      DocumentSnapshot likeDoc = await likeRef.get();

      // ✅ 사용자의 user_id 가져오기
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      String? userId = userData?['user_id'] as String? ?? '익명';
      String? profileUrl = userData?['profile_picture'] as String? ?? '';

      if (likeDoc.exists) {
        // ✅ 좋아요 취소
        await likeRef.delete();
        await postRef.update({
          'likeCount': FieldValue.increment(-1),
          'likedProfiles': FieldValue.arrayRemove([profileUrl]),
        });

        debugPrint("좋아요 취소됨");
      } else {
        // ✅ 좋아요 추가 (🔥 `user_id`도 함께 저장)
        await likeRef.set({
          'like_id': likeRef.id,
          'postId': postId,
          'uid': uid,
          'user_id': userId, // 🔥 추가된 user_id
          'created_at': FieldValue.serverTimestamp(),
        });

        await postRef.update({
          'likeCount': FieldValue.increment(1),
          'likedProfiles': FieldValue.arrayUnion([profileUrl]),
        });

        debugPrint("좋아요 추가됨");
      }
    } catch (e) {
      debugPrint("좋아요 처리 오류: $e");
      throw e;
    }
  }

  /// 🔥 특정 게시물의 좋아요 개수 가져오기
  Stream<int> getLikesCount(String postId) {
    return _firestore
        .collection('Post_Likes')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<bool> isPostLikedByUser(String postId) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      String uid = currentUser.uid;
      DocumentReference likeRef =
          _firestore.collection('Post_Likes').doc('${postId}_$uid');

      DocumentSnapshot likeDoc = await likeRef.get();
      return likeDoc.exists;
    } catch (e) {
      debugPrint("좋아요 상태 확인 오류: $e");
      return false;
    }
  }
}
