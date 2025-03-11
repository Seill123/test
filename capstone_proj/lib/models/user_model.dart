class UserModel {
  final String userName;
  final String userId;
  final String bio;
  final int followers;
  final int following;
  final String? profileImageUrl;

  UserModel({
    required this.userName,
    required this.userId,
    required this.bio,
    required this.followers,
    required this.following,
    this.profileImageUrl,
  });
}
