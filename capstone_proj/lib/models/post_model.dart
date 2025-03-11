import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String postId;
  final String uid;
  final String userId;
  final String profile_picture;
  final String postContent;
  final List<String> postImages;
  final Timestamp postTime;
  final int likeCount;
  final int commentCount;
  final List<String> likedProfiles;

  PostModel({
    required this.postId,
    required this.uid,
    required this.userId,
    required this.profile_picture,
    required this.postContent,
    required this.postImages,
    required this.postTime,
    required this.likeCount,
    required this.commentCount,
    required this.likedProfiles,
  });

  /// **Firestore 데이터를 PostModel 객체로 변환하는 함수**
  factory PostModel.fromJson(DocumentSnapshot doc) {
    Map<String, dynamic> json = doc.data() as Map<String, dynamic>;
    return PostModel(
      postId: doc.id, // ✅ Firestore 문서 ID를 postId로 설정
      uid: json['uid'] ?? '',
      userId: json['user_id'] ?? '익명',
      profile_picture: json['profileImageUrl'] ?? '',
      postContent: json['postContent'] ?? '',
      postImages: (json['postImages'] as List<dynamic>?)
              ?.map((e) => e.toString()) // 🔥 문자열 변환 확실히!
              .toList() ??
          [], // 🔥 null 처리
      postTime: json['postTime'] ?? Timestamp.now(),
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      likedProfiles: List<String>.from(json['likedProfiles'] ?? []),
    );
  }

  /// **PostModel 객체를 Firestore에 저장할 Map 형식으로 변환하는 함수**
  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'uid': uid,
      'user_id': userId,
      'profile_picture': profile_picture,
      'postContent': postContent,
      'postImages': postImages,
      'postTime': postTime,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'likedProfiles': likedProfiles,
    };
  }
}
