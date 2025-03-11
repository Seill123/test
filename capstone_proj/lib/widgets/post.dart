import 'package:capstone_proj/providers/post_provider.dart';
import 'package:capstone_proj/widgets/CommentBottomSheet.dart';
import 'package:capstone_proj/widgets/LikesBottomSheet.dart';
import 'package:capstone_proj/widgets/modal_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/models/post_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

/// 개별 게시물을 표시하는 위젯
class Post extends StatefulWidget {
  final PostModel post;

  const Post({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  bool isLiked = false; // 좋아요 상태
  int likeCount = 0; // 좋아요 개수
  int commentCount = 0;

  StreamSubscription<int>? _likeSubscription; // 좋아요 스트림 구독 변수
  StreamSubscription<int>? _commentSubscription; // 댓글 스트림 구독 변수

  @override
  void initState() {
    super.initState();
    _fetchLikeStatus();
    _fetchCommentCount();
  }

  /// 🔥 Firestore에서 좋아요 개수 실시간 감지
  void _fetchLikeStatus() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    _likeSubscription =
        postProvider.getLikesCount(widget.post.postId).listen((count) {
      if (mounted) {
        // ✅ 위젯이 트리에 존재할 때만 setState 실행
        setState(() {
          likeCount = count;
        });
      }
    });

    // ✅ Firestore에서 현재 사용자가 좋아요 눌렀는지 확인
    postProvider.isPostLikedByUser(widget.post.postId).then((liked) {
      if (mounted) {
        setState(() {
          isLiked = liked;
        });
      }
    });
  }

  /// 🔥 Firestore에서 댓글 개수를 실시간으로 가져오기
  void _fetchCommentCount() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    _commentSubscription =
        postProvider.getCommentsCount(widget.post.postId).listen((count) {
      if (mounted) {
        setState(() {
          commentCount = count;
        });
      }
    });
  }

  /// 🔥 좋아요 버튼을 클릭하면 상태 변경
  void _toggleLike() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.toggleLike(widget.post.postId);

    // ✅ Firestore에서 최신 상태를 다시 확인하여 UI 반영
    bool liked = await postProvider.isPostLikedByUser(widget.post.postId);
    if (mounted) {
      setState(() {
        isLiked = liked;
      });
    }
  }

  @override
  void dispose() {
    _likeSubscription?.cancel(); // ✅ 위젯이 제거될 때 스트림 리스너 해제
    _commentSubscription?.cancel();
    super.dispose();
  }

  /// ✅ Timestamp를 포맷팅하는 함수 추가
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate(); // Timestamp → DateTime 변환
    DateTime now = DateTime.now(); // 현재 시간

    // 게시 시간과 현재 시간의 차이 계산
    Duration difference = now.difference(dateTime);

    // 1분 이내면 '방금'
    if (difference.inMinutes < 1) {
      return '방금';
    }
    // 1시간 이내면 'X분 전'
    else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    }
    // 1일 이내면 'X시간 전'
    else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    }
    // 7일 이내면 'X일 전'
    else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    }
    // 7일 이상이면 'YYYY.MM.DD' 형식으로 출력
    else {
      return DateFormat('yyyy.MM.dd').format(dateTime);
    }
  }

  void _deletePost() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);

    if (mounted) {
      Navigator.pop(context);
    }

    try {
      await postProvider.deletePost(widget.post.postId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("게시물이 삭제되었습니다.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("게시물 삭제 실패: $e")),
      );
    }
  }

  /// 게시물 옵션 메뉴를 표시하는 함수 (수정, 삭제)
  void _showPostMenu(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    bool isMyPost = widget.post.uid == currentUid;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Color(0xFFF6F6F6),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ModalBar(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: isMyPost
                      ? [
                          // ✨ 내 게시물일 경우: 수정 & 삭제
                          _buildMenuItem(
                            text: '수정',
                            icon: Icons.edit,
                            iconColor: Color(0xFF474747),
                            onTap: () => Navigator.pop(context),
                          ),
                          Divider(
                              height: 1, thickness: 1, color: Colors.grey[300]),
                          _buildMenuItem(
                            text: '삭제',
                            icon: Icons.delete_outline,
                            iconColor: Color(0xFFFE2D56),
                            textColor: Color(0xFFFE2D56),
                            onTap: () {
                              _deletePost(); // 삭제 실행
                            },
                          ),
                        ]
                      : [
                          // ✨ 다른 사람의 게시물일 경우: 저장, 차단, 신고
                          _buildMenuItem(
                            text: '저장',
                            icon: Icons.bookmark_border,
                            iconColor: Color(0xFF474747),
                            onTap: () => Navigator.pop(context),
                          ),
                          Divider(
                              height: 1, thickness: 1, color: Colors.grey[300]),
                          _buildMenuItem(
                            text: '차단',
                            icon: Icons.block,
                            iconColor: Color(0xFFFE2D56),
                            textColor: Color(0xFFFE2D56),
                            onTap: () => Navigator.pop(context),
                          ),
                          Divider(
                              height: 1, thickness: 1, color: Colors.grey[300]),
                          _buildMenuItem(
                            text: '신고',
                            icon: Icons.flag_outlined,
                            iconColor: Color(0xFFFE2D56),
                            textColor: Color(0xFFFE2D56),
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 게시물 옵션 메뉴의 개별 항목을 생성하는 함수
  Widget _buildMenuItem({
    required String text,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Color textColor = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }

  /// 게시물 이미지를 클릭하면 전체 화면으로 확대하는 함수
  void _viewImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 프로필 및 옵션 버튼
            Row(
              children: [
                /// 프로필 이미지
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(widget.post.profile_picture),
                ),
                const SizedBox(width: 12),

                /// 사용자 이름 및 게시 시간 (왼쪽 정렬)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.userId,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(), // 오른쪽 공간 확보

                          /// 옵션 메뉴 아이콘 (... 버튼)
                          GestureDetector(
                            onTap: () => _showPostMenu(context),
                            child: const Icon(Icons.more_horiz,
                                size: 24, color: Colors.grey),
                          ),
                        ],
                      ),
                      Text(
                        _formatTimestamp(widget.post.postTime),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// 게시글 내용
            if (widget.post.postContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.postContent,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF474747)),
                    ),
                    // 🔥 추가된 여백 (텍스트와 이미지 사이 간격 조정)
                    const SizedBox(height: 8)
                  ],
                ),
              ),

            /// 이미지가 없는 경우, 높이를 맞추기 위해 여백 추가
            if (widget.post.postImages.isEmpty) const SizedBox(height: 0),

            /// 게시글 이미지 (여러 장 지원)
            if (widget.post.postImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: SizedBox(
                  height: 250,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.post.postImages.map((imageUrl) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => _viewImage(imageUrl),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 180,
                                height: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            /// 좋아요, 댓글, 번역, 공유 버튼
            Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Row(
                children: [
                  /// 좋아요 버튼
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Icon(
                      isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      size: 24,
                      color: isLiked ? Color(0xFFFE2D56) : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// 댓글 버튼
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) =>
                            CommentBottomSheet(postId: widget.post.postId),
                      );
                    },
                    child: Icon(
                      CupertinoIcons.chat_bubble,
                      size: 24,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// 번역 버튼
                  GestureDetector(
                    child: Icon(Icons.g_translate,
                        size: 24, color: Colors.grey.shade500),
                  ),
                  const SizedBox(width: 10),

                  /// 공유 버튼
                  GestureDetector(
                    child: Icon(CupertinoIcons.share,
                        size: 24, color: Colors.grey.shade500),
                  ),
                  const Spacer(),

                  /// 좋아요한 사용자 프로필 (최대 2명 표시)
                  /// 좋아요한 사용자 프로필 (최대 2명 표시)
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (context) =>
                            LikesBottomSheet(postId: widget.post.postId),
                      );
                    },
                    child: Row(
                      children: widget.post.likedProfiles
                          .take(2) // 최대 2명까지 표시
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) {
                        int index = entry.key;
                        String imageUrl = entry.value;
                        return Transform.translate(
                          offset: Offset(index == 0 ? 0 : -index * 5.0, 0),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(imageUrl),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  /// 좋아요 및 댓글 개수 표시
                  if (likeCount > 0 || commentCount > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '${likeCount > 0 ? '좋아요 $likeCount' : ''}${likeCount > 0 && commentCount > 0 ? ' · ' : ''}${commentCount > 0 ? '댓글 $commentCount' : ''}',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
