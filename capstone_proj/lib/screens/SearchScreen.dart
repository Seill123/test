import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:capstone_proj/screens/ChatRoomScreen.dart';
import 'package:capstone_proj/controllers/search_controller.dart' as AppSearch;
import 'package:provider/provider.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:developer' as developer;

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchTextController = TextEditingController();
  late AppSearch.SearchController _searchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController =
        Provider.of<AppSearch.SearchController>(context, listen: false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchTextController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchTextController.text.trim();
    if (query.isNotEmpty) {
      developer.log('검색 실행: $query', name: 'SearchScreen');
      _searchController.setSearchQuery(query);
      // 키보드 닫기
      FocusScope.of(context).unfocus();
    } else {
      // 검색어가 비어있을 때 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('검색어를 입력해주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppSearch.SearchController(),
      child: Consumer<AppSearch.SearchController>(
        builder: (context, searchController, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text('검색', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0,
              bottom: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: [
                  Tab(text: '게시물'),
                  Tab(text: '사용자'),
                ],
              ),
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchTextController,
                          decoration: InputDecoration(
                            hintText: '검색어를 입력하세요',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchTextController.clear();
                                searchController.setSearchQuery('');
                              },
                            ),
                          ),
                          onSubmitted: (_) => _performSearch(),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _performSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF477BFF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('검색'),
                      ),
                    ],
                  ),
                ),
                if (searchController.searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(
                          '검색어: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '"${searchController.searchQuery}"',
                          style: TextStyle(
                            color: Color(0xFF477BFF),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Spacer(),
                        Text(
                          _tabController.index == 0 ? '게시물 검색 결과' : '사용자 검색 결과',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostSearchResults(searchController),
                      _buildUserSearchResults(searchController),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostSearchResults(AppSearch.SearchController searchController) {
    return StreamBuilder<QuerySnapshot>(
      stream: searchController.searchPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: SelectableText.rich(
              TextSpan(
                text: '오류가 발생했습니다: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final posts = snapshot.data?.docs ?? [];

        if (posts.isEmpty) {
          return Center(
            child: Text(
              searchController.searchQuery.isEmpty
                  ? '검색어를 입력하세요'
                  : '검색 결과가 없습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index].data() as Map<String, dynamic>;
            final postId = posts[index].id;

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: post['imageUrl'] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          post['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: Icon(Icons.error),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image),
                      ),
                title: Text(post['title'] ?? '제목 없음'),
                subtitle: Text(
                  post['content'] ?? '내용 없음',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  // 게시물 상세 페이지로 이동
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => PostDetailScreen(postId: postId),
                  //   ),
                  // );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserSearchResults(AppSearch.SearchController searchController) {
    return StreamBuilder<QuerySnapshot>(
      stream: searchController.searchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          developer.log('검색 오류: ${snapshot.error}', name: 'SearchScreen');
          return Center(
            child: SelectableText.rich(
              TextSpan(
                text: '오류가 발생했습니다: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final users = snapshot.data?.docs ?? [];
        developer.log('검색 결과 수: ${users.length}', name: 'SearchScreen');

        // 검색 결과가 있으면 첫 번째 사용자 데이터 로깅
        if (users.isNotEmpty) {
          final firstUser = users.first.data() as Map<String, dynamic>;
          developer.log('첫 번째 사용자 데이터: $firstUser', name: 'SearchScreen');
        }

        final currentUserId = searchController.getCurrentUserId();

        // 현재 사용자를 결과에서 제외
        final filteredUsers =
            users.where((doc) => doc.id != currentUserId).toList();

        developer.log('필터링 후 결과 수: ${filteredUsers.length}',
            name: 'SearchScreen');

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  searchController.searchQuery.isEmpty
                      ? '검색어를 입력하세요'
                      : '검색 결과가 없습니다',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  searchController.searchQuery.isEmpty
                      ? '사용자 이름으로 검색해보세요'
                      : '다른 검색어로 시도해보세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index].data() as Map<String, dynamic>;
            final userId = filteredUsers[index].id;

            // user_name 필드 사용
            final userName = user['user_name'] ?? '이름 없음';

            // 프로필 이미지 URL 유효성 검사
            final profilePicture = user['profile_picture'];
            final bool hasValidProfileImage = profilePicture != null &&
                profilePicture.toString().isNotEmpty &&
                profilePicture.toString() != "file:///";

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: hasValidProfileImage
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(profilePicture),
                        radius: 25,
                      )
                    : CircleAvatar(
                        child: Icon(Icons.person),
                        radius: 25,
                      ),
                title: Row(
                  children: [
                    Text(userName),
                    SizedBox(width: 8),
                    if (user['native_language'] != null)
                      CountryFlag.fromCountryCode(
                        _getCountryCodeFromLanguage(user['native_language']),
                        height: 15,
                        width: 20,
                      ),
                  ],
                ),
                subtitle: Text(user['location'] ?? '위치 정보 없음'),
                trailing: IconButton(
                  icon: Icon(Icons.chat_bubble_outline),
                  onPressed: () async {
                    try {
                      final roomId =
                          await searchController.createOrGetChatRoom(userId);

                      // 사용자 정보 가져오기
                      final userInfo =
                          await searchController.getUserInfo(userId);

                      if (userInfo != null && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatRoomScreen(
                              roomId: roomId,
                              currentUserId: currentUserId ?? '',
                              userName: userInfo['user_name'] ?? '사용자',
                              countryCode: _getCountryCodeFromLanguage(
                                  userInfo['native_language'] ?? ''),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('채팅방을 열 수 없습니다: ${e.toString()}')),
                        );
                      }
                    }
                  },
                ),
                onTap: () async {
                  try {
                    final roomId =
                        await searchController.createOrGetChatRoom(userId);

                    // 사용자 정보 가져오기
                    final userInfo = await searchController.getUserInfo(userId);

                    if (userInfo != null && mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatRoomScreen(
                            roomId: roomId,
                            currentUserId: currentUserId ?? '',
                            userName: userInfo['user_name'] ?? '사용자',
                            countryCode: _getCountryCodeFromLanguage(
                                userInfo['native_language'] ?? ''),
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('채팅방을 열 수 없습니다: ${e.toString()}')),
                      );
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  // 언어 코드를 국가 코드로 변환하는 함수
  String _getCountryCodeFromLanguage(String language) {
    // 기본값
    if (language.isEmpty) return 'KR';

    // 언어 코드에 따른 국가 코드 매핑
    final Map<String, String> languageToCountry = {
      'ko': 'KR', // 한국어
      'en': 'US', // 영어
      'ja': 'JP', // 일본어
      'zh': 'CN', // 중국어
      'es': 'ES', // 스페인어
      'fr': 'FR', // 프랑스어
      'de': 'DE', // 독일어
      'it': 'IT', // 이탈리아어
      'ru': 'RU', // 러시아어
      'pt': 'PT', // 포르투갈어
      'ar': 'SA', // 아랍어
      'hi': 'IN', // 힌디어
      'bn': 'BD', // 벵골어
      'vi': 'VN', // 베트남어
      'th': 'TH', // 태국어
      'id': 'ID', // 인도네시아어
    };

    // 언어 코드가 매핑에 있으면 해당 국가 코드 반환
    if (languageToCountry.containsKey(language.toLowerCase())) {
      return languageToCountry[language.toLowerCase()]!;
    }

    // 매핑에 없으면 기본값 반환
    return 'KR';
  }
}
