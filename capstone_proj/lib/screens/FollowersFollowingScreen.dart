import 'package:flutter/material.dart';
import 'package:capstone_proj/models/user_model.dart';

// 팔로워 및 팔로잉 목록을 보여주는 화면
class FollowersFollowingScreen extends StatefulWidget {
  final UserModel user;
  final String type; // '팔로워' 또는 '팔로잉'을 전달받음

  FollowersFollowingScreen({required this.user, required this.type});

  @override
  _FollowersFollowingScreenState createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // '팔로워' 클릭 시 0번 탭, '팔로잉' 클릭 시 1번 탭을 초기 선택
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.type == '팔로워' ? 0 : 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 버튼
          },
        ),
        title: Text(
          widget.user.userName, // 사용자 이름 적용
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController, // TabController 적용
          labelColor: Color(0xFF424242),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF424242),
          indicatorSize: TabBarIndicatorSize.tab,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            Tab(text: '${widget.user.followers} 팔로워'), // 모델 데이터로 팔로워 수 적용
            Tab(text: '${widget.user.following} 팔로잉'), // 모델 데이터로 팔로잉 수 적용
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController, // TabController 적용
        children: [
          FollowersTab(followersCount: widget.user.followers), // 팔로워 탭
          FollowingTab(followingCount: widget.user.following), // 팔로잉 탭
        ],
      ),
    );
  }
}

// 팔로워 목록을 보여주는 탭
class FollowersTab extends StatelessWidget {
  final int followersCount;

  FollowersTab({required this.followersCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: followersCount, // 팔로워 수만큼 리스트 아이템 생성
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person), // 기본 아이콘 (추후 이미지 적용 가능)
          ),
          title: Text('팔로워 ${index + 1}'), // 예제 데이터로 팔로워 번호 출력
        );
      },
    );
  }
}

// 팔로잉 목록을 보여주는 탭
class FollowingTab extends StatelessWidget {
  final int followingCount;

  FollowingTab({required this.followingCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: followingCount, // 팔로잉 수만큼 리스트 아이템 생성
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person), // 기본 아이콘 (추후 이미지 적용 가능)
          ),
          title: Text('팔로잉 ${index + 1}'), // 예제 데이터로 팔로잉 번호 출력
        );
      },
    );
  }
}
