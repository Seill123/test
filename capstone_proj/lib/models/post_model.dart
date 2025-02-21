class PostModel {
  final String userName; // 사용자 이름
  final String profileImageUrl; // 사용자 프로필 이미지 URL
  final String postTime; // 게시물 작성 시간
  final String postContent; // 게시물 내용
  final List<String> postImages; // 게시물 이미지 목록
  final int likeCount; // 좋아요 수
  final int commentCount; // 댓글 수
  final List<String> likedProfiles; // 좋아요한 사용자 프로필 목록

  PostModel({
    required this.userName,
    required this.profileImageUrl,
    required this.postTime,
    required this.postContent,
    required this.postImages,
    required this.likeCount,
    required this.commentCount,
    required this.likedProfiles,
  });
}
