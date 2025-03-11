import 'package:capstone_proj/screens/FollowersFollowingScreen.dart';
import 'package:capstone_proj/screens/mypage/ProfileEditScreen.dart';
import 'package:capstone_proj/screens/mypage/SettingsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/models/user_model.dart';
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
  UserModel? user; // Firestore에서 가져올 사용자 데이터
  bool isLoading = true; // 로딩 상태

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // 사용자 프로필 데이터 가져오기
  }

  // Firestore에서 사용자 프로필 정보 가져오는 함수
  Future<void> fetchUserProfile() async {
    final firestore = FirebaseFirestore.instance;
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    String UID = currentUser.uid;

    try {
      // users 컬렉션에서 데이터 가져오기
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(UID).get();
      DocumentSnapshot profileDoc =
          await firestore.collection('user_profile').doc(UID).get();

      if (userDoc.exists && profileDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>;
        var profileData = profileDoc.data() as Map<String, dynamic>;

        setState(() {
          user = UserModel(
            userName: userData['user_name'] ?? "Unknown",
            userId: "@${userData['user_id'] ?? "unknown"}",
            bio: (profileData['bio'] == null ||
                    profileData['bio'].trim().isEmpty)
                ? "자기소개를 입력해주세요."
                : profileData['bio'],
            followers: (profileData['followers'] as List?)?.length ?? 0,
            following: (profileData['following'] as List?)?.length ?? 0,
            profileImageUrl: userData['profile_picture'],
          );
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("사용자 프로필 불러오기 오류: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // 팔로워/팔로잉 수를 표시하고 클릭 시 이동하는 위젯
  Widget _buildStatItem(
      String count, String type, BuildContext context, String userId) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FollowersFollowingScreen(
              type: type,
              userId: userId,
            ),
          ),
        );
      },
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
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : user == null
                  ? Center(child: Text("사용자 정보를 불러올 수 없습니다."))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              // 사용자 정보 및 팔로워/팔로잉 정보 표시
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(user!.userName,
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 4),
                                        Text(user!.userId,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Color(0xFFb2b2b2))),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            _buildStatItem('${user!.followers}',
                                                '팔로워', context, user!.userId),
                                            SizedBox(width: 12),
                                            _buildStatItem('${user!.following}',
                                                '팔로잉', context, user!.userId),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        _buildBioSection(),
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
                                          backgroundColor: Colors.grey[300],
                                          backgroundImage:
                                              (user!.profileImageUrl != null &&
                                                      user!.profileImageUrl!
                                                          .isNotEmpty)
                                                  ? NetworkImage(
                                                      user!.profileImageUrl!)
                                                  : null,
                                          child:
                                              (user!.profileImageUrl == null ||
                                                      user!.profileImageUrl!
                                                          .isEmpty)
                                                  ? Icon(Icons.person,
                                                      size: 40,
                                                      color: Colors.white)
                                                  : null,
                                        ),
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: CountryFlag.fromCountryCode(
                                              'KR',
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
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileEditScreen()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xFF477BFF),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Text('프로필 편집',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.grey),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        splashFactory: NoSplash.splashFactory,
                                      ),
                                      child: Text('프로필 공유',
                                          style:
                                              TextStyle(color: Colors.black)),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ), // 여기까지 Padding 적용

                        TabBar(
                          labelColor: Color(0xFF424242),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF424242),
                          indicatorSize: TabBarIndicatorSize.tab,
                          splashFactory: NoSplash.splashFactory,
                          overlayColor:
                              WidgetStateProperty.all(Colors.transparent),
                          tabs: [
                            Tab(icon: Icon(Icons.account_box)),
                            Tab(icon: Icon(Icons.grid_view_rounded)),
                            Tab(icon: Icon(Icons.calendar_month))
                          ],
                        ),

                        // abBarView는 패딩 없이 Expanded로 감싸기
                        Expanded(
                          child: TabBarView(
                            children: [ProfileTab(), FeedTab(), ScheduleTab()],
                          ),
                        ),
                      ],
                    )),
    );
  }

  // 소개 문구 표시 및 더보기 기능 구현
  Widget _buildBioSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: user!.bio,
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
              (user!.bio.trim().isEmpty) ? "자기소개를 입력해주세요." : user!.bio,
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
