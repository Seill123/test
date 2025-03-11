import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/models/post_model.dart';
import 'package:capstone_proj/providers/post_provider.dart';
import 'package:capstone_proj/widgets/post.dart';

class FeedTab extends StatelessWidget {
  const FeedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, child) {
          return StreamBuilder<List<PostModel>>(
            stream: postProvider.getUserPosts(), // ✅ 내가 작성한 게시물만 가져오기
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("내가 작성한 게시물이 없습니다."));
              }

              return RefreshIndicator.adaptive(
                color: const Color(0xFF477BFF),
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await postProvider.fetchPosts(); // ✅ 새로고침 기능 유지
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Post(post: snapshot.data![index]);
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
