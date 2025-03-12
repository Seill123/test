import 'package:capstone_proj/screens/ChatRoomScreen.dart';
import 'package:capstone_proj/screens/SearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class ChatScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "채팅",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF474747),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.person_add_alt, size: 28, color: Color(0xFF474747)),
            onPressed: () {
              print("친구 추가 클릭됨");
            },
          ),
          IconButton(
            icon: Icon(Icons.search, size: 28, color: Color(0xFF474747)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications_none,
                size: 28, color: Color(0xFF474747)),
            onPressed: () {
              print("알림 클릭됨");
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 8),

          // 스토리 영역
          _buildStorySection(currentUserId),

          // 채팅 목록
          Expanded(
            child: _buildChatList(context, currentUserId),
          ),
        ],
      ),
    );
  }

  // 스토리 섹션 구현
  Widget _buildStorySection(String? currentUserId) {
    return SizedBox(
      height: 110,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').limit(10).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            developer.log('스토리 섹션 오류: ${snapshot.error}', name: 'ChatScreen');
            return Center(
              child: Text('오류가 발생했습니다', style: TextStyle(color: Colors.red)),
            );
          }

          final users = snapshot.data?.docs ?? [];

          // 현재 사용자를 맨 앞으로 이동
          final currentUserDoc =
              users.where((doc) => doc.id == currentUserId).toList();
          final otherUsers =
              users.where((doc) => doc.id != currentUserId).toList();

          final allUsers = [...currentUserDoc, ...otherUsers];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: allUsers.length,
            itemBuilder: (context, index) {
              final user = allUsers[index].data() as Map<String, dynamic>;
              final userId = allUsers[index].id;
              final isCurrentUser = userId == currentUserId;

              return _buildStoryItem(
                index: index,
                user: user,
                userId: userId,
                isCurrentUser: isCurrentUser,
              );
            },
          );
        },
      ),
    );
  }

  // 스토리 아이템
  Widget _buildStoryItem({
    required int index,
    required Map<String, dynamic> user,
    required String userId,
    required bool isCurrentUser,
  }) {
    // user_name 필드 사용
    final displayName = user['user_name'] ?? '사용자';
    final nativeLanguage = user['native_language'] ?? '';
    final profileImageUrl = user['profile_picture'];

    // 프로필 이미지 URL 유효성 검사
    final bool hasValidProfileImage = profileImageUrl != null &&
        profileImageUrl.toString().isNotEmpty &&
        profileImageUrl.toString() != "file:///";

    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[300],
                backgroundImage:
                    hasValidProfileImage ? NetworkImage(profileImageUrl) : null,
                child: (!hasValidProfileImage)
                    ? Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              if (isCurrentUser) // 나의 스토리는 플러스 버튼 추가
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(0xFF477BFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                )
              else // 일반 유저는 국기 추가
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildFlagIcon(
                      _getCountryCodeFromLanguage(nativeLanguage)),
                ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            isCurrentUser ? "나의 스토리" : displayName,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 채팅 목록 구현
  Widget _buildChatList(BuildContext context, String? currentUserId) {
    if (currentUserId == null) {
      return Center(child: Text('로그인이 필요합니다'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chatRooms')
          .where('userIds', arrayContains: currentUserId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          developer.log('채팅 목록 오류: ${snapshot.error}', name: 'ChatScreen');
          return Center(
            child: SelectableText.rich(
              TextSpan(
                text: '오류가 발생했습니다: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final chatRooms = snapshot.data?.docs ?? [];

        if (chatRooms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '채팅방이 없습니다',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  '검색을 통해 사용자를 찾고 채팅을 시작해보세요',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                  child: Text('사용자 검색하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF477BFF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = chatRooms[index].data() as Map<String, dynamic>;
            final roomId = chatRooms[index].id;
            final userIds = List<String>.from(chatRoom['userIds'] ?? []);

            // 상대방 ID 찾기
            final otherUserId = userIds.firstWhere(
              (id) => id != currentUserId,
              orElse: () => '',
            );

            if (otherUserId.isEmpty) {
              return SizedBox.shrink();
            }

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 30, color: Colors.white),
                    ),
                    title: Text('로딩 중...'),
                    subtitle: Text(''),
                  );
                }

                final userData =
                    userSnapshot.data?.data() as Map<String, dynamic>? ?? {};

                // user_name 필드 사용
                final userName = userData['user_name'] ?? '사용자';
                final nativeLanguage = userData['native_language'] ?? '';
                final profileImageUrl = userData['profile_picture'];

                final lastMessage = chatRoom['lastMessage'] ?? '';
                final lastMessageTime =
                    chatRoom['lastMessageTime'] as Timestamp?;
                final unreadCount = chatRoom['unreadCount_$currentUserId'] ?? 0;

                return _buildChatItem(
                  context: context,
                  roomId: roomId,
                  currentUserId: currentUserId,
                  userName: userName,
                  countryCode: _getCountryCodeFromLanguage(nativeLanguage),
                  profileImageUrl: profileImageUrl,
                  lastMessage: lastMessage,
                  lastMessageTime: lastMessageTime,
                  unreadCount: unreadCount,
                );
              },
            );
          },
        );
      },
    );
  }

  // 채팅 리스트 아이템
  Widget _buildChatItem({
    required BuildContext context,
    required String roomId,
    required String currentUserId,
    required String userName,
    required String countryCode,
    String? profileImageUrl,
    required String lastMessage,
    Timestamp? lastMessageTime,
    required int unreadCount,
  }) {
    final formattedTime = lastMessageTime != null
        ? _formatChatTime(lastMessageTime.toDate())
        : '';

    // 프로필 이미지 URL 유효성 검사
    final bool hasValidProfileImage = profileImageUrl != null &&
        profileImageUrl.toString().isNotEmpty &&
        profileImageUrl.toString() != "file:///";

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage:
                hasValidProfileImage ? NetworkImage(profileImageUrl) : null,
            child: (!hasValidProfileImage)
                ? Icon(Icons.person, size: 30, color: Colors.white)
                : null,
          ),
          // 국가 플래그 추가
          Positioned(
            right: 0,
            bottom: 0,
            child: _buildFlagIcon(countryCode),
          ),
        ],
      ),
      title: Row(
        children: [
          Text(
            userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      subtitle: Text(
        lastMessage.isNotEmpty ? lastMessage : '새로운 채팅방',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formattedTime,
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(height: 5),
          if (unreadCount > 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFF477BFF),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
      onTap: () {
        // 클릭하면 해당 채팅방으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomId: roomId,
              currentUserId: currentUserId,
              userName: userName,
              countryCode: countryCode,
            ),
          ),
        );
      },
    );
  }

  /// 🔹 국가 플래그 아이콘 빌드 함수
  Widget _buildFlagIcon(String countryCode) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // 모서리를 둥글게
        child: CountryFlag.fromCountryCode(
          countryCode,
          height: 18,
          width: 18,
        ),
      ),
    );
  }

  // 채팅 시간 포맷팅
  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 오늘 메시지는 시간만 표시
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      // 어제 메시지
      return '어제';
    } else if (now.difference(dateTime).inDays < 7) {
      // 일주일 이내는 요일 표시
      final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
      final weekday = weekdays[dateTime.weekday - 1];
      return '$weekday요일';
    } else {
      // 그 외에는 날짜 표시
      return DateFormat('MM/dd').format(dateTime);
    }
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
