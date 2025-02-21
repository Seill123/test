import 'package:flutter/material.dart';
import 'package:capstone_proj/models/user_model.dart';
import 'package:capstone_proj/screens/FollowersFollowingScreen.dart';
import 'package:capstone_proj/screens/mypage/feed_tab.dart';
import 'package:capstone_proj/screens/mypage/profile_tab.dart';
import 'package:capstone_proj/screens/mypage/schedule_tab.dart';

class OtherUserPage extends StatefulWidget {
  final String userId; // 상대방 userId

  OtherUserPage({required this.userId});

  @override
  _OtherUserPageState createState() => _OtherUserPageState();
}

class _OtherUserPageState extends State<OtherUserPage> {
  bool isFollowing = false; // 팔로우 상태
  bool showFullText = false; // 더보기 버튼 상태
  bool isPraised = false; // 칭찬 상태 추가

  // 🔥 임시 상대방 프로필 데이터 (실제 앱에서는 userId 기반 API 호출 필요)
  late UserModel user = UserModel(
    userName: "상대방", // 상대방 이름
    userId: "@otherUser", // 상대방 ID
    bio: "이곳은 상대방의 소개글입니다.", // 상대방 소개글
    followers: 100, // 팔로워 수
    following: 50, // 팔로잉 수
    profileImageUrl: null, // 기본 이미지 사용 가능
  );

  // 팔로워/팔로잉 화면으로 이동하는 함수
  void _navigateToFollowersFollowing(BuildContext context, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowersFollowingScreen(user: user, type: type),
      ),
    );
  }

  // 통계 항목 (팔로워, 팔로잉)
  Widget _buildStatItem(String count, String type, BuildContext context) {
    return InkWell(
      onTap: () => _navigateToFollowersFollowing(context, type),
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          Text(count,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 4),
          Text(type, style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭 개수
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.ios_share_outlined, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.black), // 추가된 아이콘
              onPressed: () {},
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 사용자 정보 및 팔로워/팔로잉 정보
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.userName,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(user.userId,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFFb2b2b2))),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatItem('${user.followers}', '팔로워', context),
                            SizedBox(width: 12),
                            _buildStatItem('${user.following}', '팔로잉', context),
                          ],
                        ),
                        SizedBox(height: 12),
                        _buildBioSection(), // 소개글 + 더보기 버튼
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null, // 기본 이미지
                        ),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.flag,
                              color: Color(0xFF477BFF), size: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 팔로우/언팔로우 버튼
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isFollowing = !isFollowing;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isFollowing ? Colors.grey[300] : Color(0xFF477BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isFollowing ? '팔로잉' : '팔로우',
                        style: TextStyle(
                            color: isFollowing ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    // Use Expanded here for equal width
                    child: OutlinedButton(
                      onPressed: () {
                        // 메시지 기능 추가 가능
                      },
                      style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          splashFactory: NoSplash.splashFactory),
                      child: Text("메시지",
                          style: TextStyle(color: Colors.black)), // 메시지 텍스트 버튼
                    ),
                  ),
                  SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        isPraised = !isPraised; // 칭찬 상태 변경
                      });
                    },
                    style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        splashFactory: NoSplash.splashFactory),
                    child: Icon(
                      isPraised
                          ? Icons.thumb_up_off_alt_rounded // 채워진 아이콘
                          : Icons.thumb_up_off_alt_outlined, // 빈 아이콘
                      color: Color(0xFF477BFF),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),
              // 탭바
              TabBar(
                labelColor: Color(0xFF424242),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF424242),
                indicatorSize: TabBarIndicatorSize.tab,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                tabs: [
                  Tab(icon: Icon(Icons.account_box)), // 프로필 탭
                  Tab(icon: Icon(Icons.grid_view_rounded)), // 피드 탭
                  Tab(icon: Icon(Icons.calendar_month)) // 일정 탭
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [ProfileTab(), FeedTab(), ScheduleTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 소개 문구 + 더보기 버튼
  Widget _buildBioSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: user.bio,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        bool isOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.bio,
              style: TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: showFullText ? null : 2,
              overflow: showFullText ? null : TextOverflow.ellipsis,
            ),
            Visibility(
              visible: isOverflowing && !showFullText,
              child: InkWell(
                onTap: () {
                  setState(() {
                    showFullText = true;
                  });
                },
                child: Text(
                  '더보기',
                  style: TextStyle(
                      color: Color(0xFF477BFF),
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
