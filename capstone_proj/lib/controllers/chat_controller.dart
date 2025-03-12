import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

class ChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseFirestore get firestore => _firestore;

  // 채팅방 생성
  Future<String> createChatRoom({
    required String name,
    required List<String> participants,
    required bool isGroup,
  }) async {
    final chatRoom = ChatRoom(
      id: '',
      name: name,
      participants: participants,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
      isGroup: isGroup,
      readStatus: Map.fromIterable(participants, value: (p) => false),
    );

    final docRef =
        await _firestore.collection('chatRooms').add(chatRoom.toMap());
    return docRef.id;
  }

  // 채팅방 목록 가져오기
  Stream<List<ChatRoom>> getChatRooms(String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList());
  }

  // 메시지 전송
  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
    required MessageType type,
    File? file,
  }) async {
    String? fileUrl;
    String? fileName;

    if (file != null &&
        (type == MessageType.image || type == MessageType.file)) {
      try {
        final ref = _storage.ref().child(
            'chat_files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');
        await ref.putFile(file);
        fileUrl = await ref.getDownloadURL();
        fileName = file.path.split('/').last;
      } catch (e) {
        print('파일 업로드 오류: $e');
        // 파일 업로드 실패 시에도 메시지는 전송
      }
    }

    final message = ChatMessage(
      id: '',
      senderId: senderId,
      content: content,
      timestamp: DateTime.now(),
      type: type,
      readBy: {},
      fileUrl: fileUrl,
      fileName: fileName,
    );

    try {
      final roomRef = _firestore.collection('chatRooms').doc(roomId);
      final room = await roomRef.get();

      // 채팅방이 존재하지 않는 경우 처리
      if (!room.exists) {
        throw Exception('채팅방을 찾을 수 없습니다');
      }

      // participants 필드가 null이거나 List가 아닌 경우 안전하게 처리
      List<String> participants = [];
      if (room.data() != null && room.data()!.containsKey('participants')) {
        final participantsData = room.data()!['participants'];
        if (participantsData is List) {
          participants = List<String>.from(participantsData);
        }
      }

      // participants가 비어있는 경우 현재 사용자만 추가
      if (participants.isEmpty) {
        participants = [senderId];
      }

      // 메시지 추가
      await _firestore
          .collection('chatRooms/$roomId/messages')
          .add(message.toMap());

      // 채팅방 정보 업데이트
      await roomRef.update({
        'lastMessage': content,
        'lastMessageTime': message.timestamp,
        'readStatus':
            Map.fromIterable(participants, value: (p) => p == senderId),
      });
    } catch (e) {
      print('메시지 전송 오류: $e');
      rethrow;
    }
  }

  // 메시지 읽음 표시
  Future<void> markAsRead(String roomId, String userId) async {
    final messages = await _firestore
        .collection('chatRooms/$roomId/messages')
        .where('readBy.$userId', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.update(doc.reference, {
        'readBy.$userId': true,
      });
    }
    await batch.commit();
  }

  // 채팅방 검색
  Stream<List<ChatRoom>> searchChatRooms(String query, String userId) {
    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoom.fromFirestore(doc))
            .where(
                (room) => room.name.toLowerCase().contains(query.toLowerCase()))
            .toList());
  }

  // 채팅방 고정/해제
  Future<void> togglePinRoom(String roomId, bool isPinned) async {
    await _firestore.collection('chatRooms').doc(roomId).update({
      'isPinned': isPinned,
    });
  }

  // 채팅방 알림 설정
  Future<void> toggleNotification(String roomId, bool enabled) async {
    await _firestore.collection('chatRooms').doc(roomId).update({
      'notificationEnabled': enabled,
    });
  }

  // 채팅방 나가기
  Future<void> leaveRoom(String roomId, String userId) async {
    final roomRef = _firestore.collection('chatRooms').doc(roomId);
    final room = await roomRef.get();

    if (!room.exists) return;

    final participants = List<String>.from(room.data()?['participants'] ?? []);
    participants.remove(userId);

    if (participants.isEmpty) {
      await roomRef.delete();
    } else {
      await roomRef.update({
        'participants': participants,
      });
    }
  }
}
