import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FollowersFollowingScreen extends StatefulWidget {
  final String type; // '팔로워' 또는 '팔로잉'
  final String userId; // Firestore에서 데이터를 가져오기 위한 UID

  FollowersFollowingScreen({required this.type, required this.userId});

  @override
  _FollowersFollowingScreenState createState() =>
      _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<String> followers = [];
  List<String> following = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.type == '팔로워' ? 0 : 1,
    );
    fetchFollowersAndFollowing();
  }

  Future<void> fetchFollowersAndFollowing() async {
    try {
      DocumentSnapshot profileDoc = await FirebaseFirestore.instance
          .collection('user_profile')
          .doc(widget.userId)
          .get();

      if (profileDoc.exists) {
        var data = profileDoc.data() as Map<String, dynamic>;

        setState(() {
          followers = List<String>.from(data['followers'] ?? []);
          following = List<String>.from(data['following'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      print("팔로워/팔로잉 불러오기 오류: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.type, // "팔로워" 또는 "팔로잉"
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xFF424242),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xFF424242),
          indicatorSize: TabBarIndicatorSize.tab,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            Tab(text: '${followers.length} 팔로워'),
            Tab(text: '${following.length} 팔로잉'),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                FollowersTab(followers: followers),
                FollowingTab(following: following),
              ],
            ),
    );
  }
}

// ✅ Firestore에서 가져온 팔로워 데이터 표시
class FollowersTab extends StatelessWidget {
  final List<String> followers;

  FollowersTab({required this.followers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: followers.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(followers[index])
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ListTile(
                title: Text("불러오는 중..."),
                leading: CircleAvatar(child: Icon(Icons.person)),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: userData['profile_picture'] != null
                    ? NetworkImage(userData['profile_picture'])
                    : null,
                child: userData['profile_picture'] == null
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(userData['user_name'] ?? "Unknown"),
              subtitle: Text("@${userData['user_id'] ?? "unknown"}"),
            );
          },
        );
      },
    );
  }
}

// ✅ Firestore에서 가져온 팔로잉 데이터 표시
class FollowingTab extends StatelessWidget {
  final List<String> following;

  FollowingTab({required this.following});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: following.length,
      itemBuilder: (context, index) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .doc(following[index])
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return ListTile(
                title: Text("불러오는 중..."),
                leading: CircleAvatar(child: Icon(Icons.person)),
              );
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: userData['profile_picture'] != null
                    ? NetworkImage(userData['profile_picture'])
                    : null,
                child: userData['profile_picture'] == null
                    ? Icon(Icons.person)
                    : null,
              ),
              title: Text(userData['user_name'] ?? "Unknown"),
              subtitle: Text("@${userData['user_id'] ?? "unknown"}"),
            );
          },
        );
      },
    );
  }
}
