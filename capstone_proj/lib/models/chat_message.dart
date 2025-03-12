import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final Map<String, bool> readBy;
  final String? fileUrl;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.readBy,
    this.fileUrl,
    this.fileName,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${data['type']}',
        orElse: () => MessageType.text,
      ),
      readBy: Map<String, bool>.from(data['readBy'] ?? {}),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'readBy': readBy,
      'fileUrl': fileUrl,
      'fileName': fileName,
    };
  }
}
