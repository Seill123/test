import 'package:capstone_proj/screens/mypage/SettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/models/user_model.dart';
import 'package:capstone_proj/screens/FollowersFollowingScreen.dart';
import 'package:capstone_proj/screens/mypage/feed_tab.dart';
import 'package:capstone_proj/screens/mypage/profile_tab.dart';
import 'package:capstone_proj/screens/mypage/schedule_tab.dart';
import 'package:country_flags/country_flags.dart';

// Mypagescreen 클래스 정의: 사용자의 마이페이지를 표시하는 화면
class Mypagescreen extends StatefulWidget {
  @override
  _MypagescreenState createState() => _MypagescreenState();
}

class _MypagescreenState extends State<Mypagescreen> {
  bool showFullText = false; // 더보기 버튼 상태를 저장하는 변수

  // 🔥 더미 데이터: 실제 앱에서는 API 또는 DB에서 가져오는 데이터
  final UserModel user = UserModel(
    userName: "taehwan", // 사용자 이름
    userId: "@hyeontaehwan", // 사용자 아이디
    bio: "나를 소개해보세요.", // 사용자 소개
    followers: 20, // 팔로워 수
    following: 8, // 팔로잉 수
    profileImageUrl: null, // 프로필 이미지 URL (기본 이미지 사용 가능)
  );

  // 팔로워/팔로잉 화면으로 이동하는 함수
  void _navigateToFollowersFollowing(
      BuildContext context, UserModel user, String type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FollowersFollowingScreen(user: user, type: type), // ✅ type 파라미터 추가
      ),
    );
  }

  // 통계 항목(팔로워, 팔로잉)을 표시하는 위젯
  Widget _buildStatItem(
      String count, String type, BuildContext context, UserModel user) {
    return InkWell(
      onTap: () {
        _navigateToFollowersFollowing(context, user, type); // ✅ type 전달
      },
      splashFactory: NoSplash.splashFactory,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        children: [
          Text(
            count, // 팔로워 또는 팔로잉 수
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 4),
          Text(
            type, // "팔로워" 또는 "팔로잉"
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 탭의 개수 설정 (프로필, 피드, 일정 탭)
      child: Scaffold(
        backgroundColor: Colors.white, // 배경색
        appBar: AppBar(
          backgroundColor: Colors.white, // 앱바 배경색
          elevation: 0, // 그림자 제거
          leading: IconButton(
            icon: Icon(Icons.bar_chart, color: Colors.black), // 메뉴 버튼
            onPressed: () {},
          ),
          actions: [
            // 공유 아이콘 버튼
            IconButton(
              icon: Icon(Icons.ios_share_outlined, color: Colors.black),
              onPressed: () {},
            ),
            // 설정 아이콘 버튼
            IconButton(
              icon: Icon(Icons.settings, color: Colors.black),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SettingsScreen()), // 설정 화면으로 이동
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // 사용자 정보 및 팔로워/팔로잉 정보 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 사용자 이름
                        Text(
                          user.userName,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        // 사용자 아이디
                        Text(
                          user.userId,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFb2b2b2),
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            // 팔로워, 팔로잉 항목
                            _buildStatItem(
                                '${user.followers}', '팔로워', context, user),
                            SizedBox(width: 12),
                            _buildStatItem(
                                '${user.following}', '팔로잉', context, user),
                          ],
                        ),

                        SizedBox(height: 12),
                        _buildBioSection(), // 🔥 사용자 소개 + 더보기 버튼
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // 프로필 이미지
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null, // 기본 이미지 처리 가능
                        ),
                        // 플래그 아이콘
                        // 국기 아이콘 적용
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(8), // 모서리를 둥글게 만듦
                            child: CountryFlag.fromCountryCode(
                              'KR', // 대한민국 국기
                              height: 18,
                              width: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // 프로필 수정 및 프로필 공유 버튼
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF477BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '프로필 수정',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        '프로필 공유',
                        style: TextStyle(color: Colors.black),
                      ),
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
              // 탭에 해당하는 뷰
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

  // 소개 문구 표시 및 더보기 기능 구현
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
            // 사용자 소개 텍스트
            Text(
              user.bio,
              style: TextStyle(color: Colors.grey, fontSize: 14),
              maxLines: showFullText ? null : 2,
              overflow: showFullText ? null : TextOverflow.ellipsis,
            ),
            // '더보기' 버튼
            Visibility(
              visible: isOverflowing && !showFullText,
              child: InkWell(
                onTap: () {
                  setState(() {
                    showFullText = true; // '더보기' 클릭 시 전체 텍스트 보기
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
