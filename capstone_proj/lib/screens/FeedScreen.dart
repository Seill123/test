import 'package:flutter/material.dart';
import 'package:capstone_proj/models/post_model.dart';
import 'package:capstone_proj/widgets/post.dart';

class Feedscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffd9d9d9),
      body: ListView(
        children: [
          Post(
            post: PostModel(
              userName: 'brunomars',
              profileImageUrl: 'https://picsum.photos/150',
              postTime: '1분 전',
              postContent: 'Another adventure with friends 🌙',
              postImages: [
                'https://picsum.photos/400',
                'https://picsum.photos/405',
                'https://picsum.photos/408',
              ],
              likeCount: 2,
              commentCount: 5,
              likedProfiles: [
                'https://picsum.photos/200',
                'https://picsum.photos/100',
              ],
            ),
          ),
          Post(
            post: PostModel(
              userName: '__youngbae__',
              profileImageUrl: 'https://picsum.photos/15',
              postTime: '3분 전',
              postContent: 'Another adventure with friends 🌙',
              postImages: [],
              likeCount: 3,
              commentCount: 2,
              likedProfiles: [
                'https://picsum.photos/200',
                'https://picsum.photos/60',
                'https://picsum.photos/70',
              ],
            ),
          ),
          Post(
            post: PostModel(
              userName: 'xxxibgdrgn',
              profileImageUrl: 'https://picsum.photos/2',
              postTime: '3분 전',
              postContent: 'Another adventure with friends 🌙',
              postImages: [
                'https://picsum.photos/557',
              ],
              likeCount: 1,
              commentCount: 5,
              likedProfiles: [
                'https://picsum.photos/20',
              ],
            ),
          ),
        ],
      ),
    );
  }
}
