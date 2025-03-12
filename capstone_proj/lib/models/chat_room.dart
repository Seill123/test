import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool isGroup;
  final bool isPinned;
  final Map<String, bool> readStatus;
  final bool notificationEnabled;

  ChatRoom({
    required this.id,
    required this.name,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.isGroup,
    this.isPinned = false,
    required this.readStatus,
    this.notificationEnabled = true,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoom(
      id: doc.id,
      name: data['name'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      isGroup: data['isGroup'] ?? false,
      isPinned: data['isPinned'] ?? false,
      readStatus: Map<String, bool>.from(data['readStatus'] ?? {}),
      notificationEnabled: data['notificationEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'isGroup': isGroup,
      'isPinned': isPinned,
      'readStatus': readStatus,
      'notificationEnabled': notificationEnabled,
    };
  }
}
