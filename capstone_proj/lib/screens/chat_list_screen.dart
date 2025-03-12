import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_room.dart';
import 'ChatRoomScreen.dart';
import 'create_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({Key? key, required this.currentUserId})
      : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatController _chatController = ChatController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _navigateToCreateChat() async {
    // 실제 앱에서는 사용자 목록을 데이터베이스에서 가져와야 합니다
    final List<String> dummyUsers = [
      widget.currentUserId,
      'user1',
      'user2',
      'user3',
      'user4',
    ];

    final String? roomId = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateChatScreen(
          currentUserId: widget.currentUserId,
          availableUsers: dummyUsers,
        ),
      ),
    );

    if (roomId != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatRoomScreen(
            roomId: roomId,
            currentUserId: widget.currentUserId,
            userName: 'User Name',
            countryCode: 'KR',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '채팅방 검색',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ChatRoom>>(
              stream: _searchQuery.isEmpty
                  ? _chatController.getChatRooms(widget.currentUserId)
                  : _chatController.searchChatRooms(
                      _searchQuery, widget.currentUserId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rooms = snapshot.data!;
                final pinnedRooms =
                    rooms.where((room) => room.isPinned).toList();
                final unpinnedRooms =
                    rooms.where((room) => !room.isPinned).toList();

                return ListView(
                  children: [
                    if (pinnedRooms.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('고정된 채팅방',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...pinnedRooms.map((room) => _buildChatRoomTile(room)),
                    ],
                    if (unpinnedRooms.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('채팅방',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ...unpinnedRooms.map((room) => _buildChatRoomTile(room)),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatRoomTile(ChatRoom room) {
    final unreadCount = room.readStatus[widget.currentUserId] == false ? 1 : 0;

    return ListTile(
      leading: CircleAvatar(
        child: Text(room.name[0]),
      ),
      title: Text(room.name),
      subtitle: Text(
        room.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatDateTime(room.lastMessageTime),
            style: const TextStyle(fontSize: 12),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoomScreen(
              roomId: room.id,
              currentUserId: widget.currentUserId,
              userName: room.name,
              countryCode: 'KR',
            ),
          ),
        );
      },
      onLongPress: () {
        _showRoomOptions(room);
      },
    );
  }

  void _showRoomOptions(ChatRoom room) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                    room.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                title: Text(room.isPinned ? '고정 해제' : '채팅방 고정'),
                onTap: () async {
                  await _chatController.togglePinRoom(room.id, !room.isPinned);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(room.notificationEnabled
                    ? Icons.notifications_off
                    : Icons.notifications),
                title: Text(room.notificationEnabled ? '알림 끄기' : '알림 켜기'),
                onTap: () async {
                  await _chatController.toggleNotification(
                      room.id, !room.notificationEnabled);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('채팅방 나가기'),
                onTap: () async {
                  await _chatController.leaveRoom(
                      room.id, widget.currentUserId);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${_getDayOfWeek(dateTime.weekday)}';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  String _getDayOfWeek(int weekday) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[weekday - 1];
  }
}
