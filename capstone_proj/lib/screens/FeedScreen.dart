import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/models/post_model.dart';
import 'package:capstone_proj/providers/post_provider.dart';
import 'package:capstone_proj/widgets/post.dart';

class Feedscreen extends StatelessWidget {
  const Feedscreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff7f7f7),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return StreamBuilder<List<PostModel>>(
            stream: postProvider.getPosts(), // 게시물 스트림 구독
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("게시물이 없습니다."));
              }

              List<PostModel> posts = snapshot.data!;

              return RefreshIndicator.adaptive(
                color: Color(0xFF477BFF),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await postProvider.fetchPosts(); // ✅ 새로고침 시 데이터 다시 불러오기
                },
                child: ListView.builder(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // ✅ 항상 스크롤 가능하게 설정
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    return Post(post: posts[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
