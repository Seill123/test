import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'modal_bar.dart';

class LikesBottomSheet extends StatelessWidget {
  final String postId;

  const LikesBottomSheet({Key? key, required this.postId}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchLikedUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Post_Likes')
        .where('postId', isEqualTo: postId)
        .get();

    List<Map<String, dynamic>> users = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> likeData = doc.data() as Map<String, dynamic>;
      String uid = likeData['uid'];

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        users.add({
          'userId': userData['user_id'] ?? '익명',
          'userName': userData['user_name'] ?? '',
          'profileImage': userData['profile_picture'] ?? '',
          'isFollowing': userData['isFollowing'] ?? false,
        });
      }
    }
    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const ModalBar(),
          const Text(
            "좋아요",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchLikedUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("좋아요한 사용자가 없습니다."));
                }
                final users = snapshot.data!;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage:
                                users[index]['profileImage'].isNotEmpty
                                    ? NetworkImage(users[index]['profileImage'])
                                    : null,
                            child: users[index]['profileImage'].isEmpty
                                ? const Icon(Icons.person, size: 24)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  users[index]['userId'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  users[index]['userName'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFFE2D56),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: users[index]['isFollowing']
                                  ? Colors.grey[300]
                                  : Color(0xFF477BFF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: Text(
                              users[index]['isFollowing'] ? "팔로잉" : "팔로우",
                              style: TextStyle(
                                  color: users[index]['isFollowing']
                                      ? Colors.black
                                      : Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 자신의 게시물에 자신이 좋아요 누른경우 팔로우 버튼 지우기
