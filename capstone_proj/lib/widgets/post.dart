import 'package:capstone_proj/widgets/modal_bar.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/models/post_model.dart';

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

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likeCount; // 초기 좋아요 개수 설정
  }

  /// 좋아요 버튼을 클릭하면 상태를 변경
  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1;
    });
  }

  /// 게시물 옵션 메뉴를 표시하는 함수 (수정, 삭제)
  void _showPostMenu(BuildContext context) {
    String currentUser = "brunomars"; // 여기에 현재 로그인한 유저의 아이디를 저장하는 방식으로 변경해야 함.

    bool isMyPost = widget.post.userName == currentUser; // 내 게시물인지 판별

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
                            onTap: () => Navigator.pop(context),
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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0.5),
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
                  backgroundImage: NetworkImage(widget.post.profileImageUrl),
                ),
                const SizedBox(width: 12),

                /// 사용자 이름 및 게시 시간
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        widget.post.postTime,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                /// 팔로우 버튼 및 옵션 메뉴 버튼
                Row(
                  children: [
                    Text(
                      '팔로우',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF477BFF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.more_horiz,
                          color: Color(0xFF474747)),
                      onPressed: () => _showPostMenu(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            /// 게시글 내용
            if (widget.post.postContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  widget.post.postContent,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            const SizedBox(height: 12),

            /// 게시글 이미지 (여러 장 지원)
            if (widget.post.postImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 46),
                child: SizedBox(
                  height: 200,
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
                                width: 150,
                                height: 200,
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
            const SizedBox(height: 16),

            /// 좋아요 및 댓글 버튼
            Padding(
              padding: const EdgeInsets.only(left: 46),
              child: Row(
                children: [
                  /// 좋아요 버튼
                  GestureDetector(
                    onTap: _toggleLike,
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 28,
                          color: isLiked
                              ? Color(0xFFFF0000)
                              : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text('$likeCount'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// 댓글 버튼
                  GestureDetector(
                    //onTap: _openComments, // 댓글 창 열기 기능 추가
                    child: Row(
                      children: [
                        Icon(Icons.comment_outlined,
                            size: 28, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text('${widget.post.commentCount}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// 번역 버튼
                  GestureDetector(
                    //onTap: _translatePost, // 번역 기능 추가
                    child: Row(
                      children: [
                        Icon(Icons.g_translate,
                            size: 28, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  /// 공유 버튼
                  GestureDetector(
                    //onTap: _sharePost, // 공유 기능 추가
                    child: Row(
                      children: [
                        Icon(Icons.ios_share,
                            size: 28, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const Spacer(),

                  /// 좋아요한 사용자 프로필 (최대 4명 표시)
                  Row(
                    children: widget.post.likedProfiles
                        .take(4)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      int index = entry.key;
                      String imageUrl = entry.value;
                      return Transform.translate(
                        offset: Offset(-index * 5.0, 0),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
