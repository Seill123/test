import 'package:capstone_proj/screens/FeedScreen.dart';
import 'package:capstone_proj/screens/ScheduleScreen.dart';
import 'package:flutter/material.dart';
import 'package:capstone_proj/screens/UploadScreen.dart';
import 'package:capstone_proj/screens/MyPageScreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 각 탭에 해당하는 화면
  final List<Widget> _screens = [
    Center(child: Text('홈 화면')), // TabBar 적용
    Center(child: Text('채팅 화면')),
    UploadScreen(), // UploadScreen은 Navigator로 푸시
    Center(child: Text('지도 화면')),
    Mypagescreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // UploadScreen을 바텀시트로 표시
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // 화면의 높이를 조절할 수 있도록 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.92, // 전체 화면의 80% 높이로 설정
          child: UploadScreen(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              title: Image.asset(
                'assets/applogo.png',
                height: 28,
              ),
              /*? DropdownButton<String>(
                value: '팔로잉',
                icon: Icon(Icons.arrow_drop_down),
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  // 드롭다운 선택 시 동작
                },
                items: <String>['팔로잉', '추천']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                }).toList(),
              )*/
              actions: _selectedIndex == 0
                  ? [
                      IconButton(
                        icon: Icon(Icons.person_add),
                        onPressed: () {
                          // 프로필 버튼 동작
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          // 검색 버튼 동작
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          // 알림 버튼 동작
                        },
                      ),
                    ]
                  : null,
              elevation: 0,
              bottom: _selectedIndex == 0
                  ? TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      controller: _tabController,
                      labelColor: Color(0xFF424242),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.black,
                      indicatorSize: TabBarIndicatorSize.tab,
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      tabs: [
                        Tab(
                          child: Text(
                            '추천',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '팔로잉',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            '일정',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    )
                  : null,
            )
          : null,
      body: _selectedIndex == 0
          ? TabBarView(
              controller: _tabController,
              children: [
                Feedscreen(), // 피드 화면
                ScheduleScreen(), // 일정 화면
                Center(child: Text('새로운 탭 화면')), // 새 탭 화면 추가
              ],
            )
          : IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '채팅',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '업로드',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '지도',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Color(0xFF477BFF),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
      ),
    );
  }
}
