import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_proj/providers/post_provider.dart';
import 'package:capstone_proj/widgets/modal_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId; // 댓글이 속한 게시물의 ID

  const CommentBottomSheet({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  // 댓글 추가 메서드
  void _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await Provider.of<PostProvider>(context, listen: false).addComment(
        postId: widget.postId,
        content: _commentController.text.trim(),
      );

      _commentController.clear();
      FocusScope.of(context).unfocus(); //키보드 자동 닫기
    } catch (e) {
      debugPrint("댓글 추가 오류: $e");
    }
  }

  // Firestore Timestamp → 상대적 시간 변환
  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '방금 전';
    try {
      DateTime postTime = timestamp.toDate();
      Duration difference = DateTime.now().difference(postTime);

      if (difference.inMinutes < 1) return '방금 전';
      if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
      if (difference.inHours < 24) return '${difference.inHours}시간 전';
      return '${difference.inDays}일 전';
    } catch (e) {
      return '알 수 없음';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream:
                Provider.of<PostProvider>(context).getComments(widget.postId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Map<String, dynamic>> comments = snapshot.data ?? [];

              return Column(
                children: [
                  const ModalBar(),
                  Row(
                    children: [
                      const Text(
                        '댓글',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '총 ${comments.length}건',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: comments.isEmpty
                        ? const Center(child: Text("댓글이 없습니다."))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              return _buildCommentItem(comments[index]);
                            },
                          ),
                  ),
                  _buildCommentInputField(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// 🔹 댓글 UI
  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 프로필 이미지
          CircleAvatar(
            radius: 18,
            backgroundImage: comment['profileImageUrl'] != null &&
                    comment['profileImageUrl'].toString().isNotEmpty
                ? NetworkImage(comment['profileImageUrl'])
                : const AssetImage('assets/default_profile.png')
                    as ImageProvider,
          ),
          const SizedBox(width: 10), // 프로필과 텍스트 간격 줄이기

          /// 아이디 + 시간 + 옵션 아이콘 + 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 아이디 + 시간 + 옵션 아이콘 (한 줄)
                Row(
                  children: [
                    Text(
                      '${comment['user_id'] ?? '익명'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment['created_at']),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(), // 🔥 오른쪽으로 밀기

                    /// **아이콘 버튼 대신 단순한 아이콘**
                    GestureDetector(
                      onTap: () {
                        print('아이콘 클릭됨!');
                      },
                      child: const Icon(Icons.more_horiz,
                          size: 20, color: Colors.grey),
                    )
                  ],
                ),

                /// 내용 (한 줄 아래 배치)
                const SizedBox(height: 4),
                Text(
                  comment['content'] ?? '',
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                SizedBox(
                  height: 4,
                ),
                Text(
                  '답글',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16)
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 댓글 입력창 UI
  Widget _buildCommentInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 입력해주세요.',
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _addComment,
            child: const Text('게시', style: TextStyle(color: Color(0xFF477BFF))),
          ),
        ],
      ),
    );
  }
}
