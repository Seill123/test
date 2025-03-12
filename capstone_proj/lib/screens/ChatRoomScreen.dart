import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String userName;
  final String countryCode;

  const ChatRoomScreen({
    Key? key,
    required this.roomId,
    required this.currentUserId,
    required this.userName,
    required this.countryCode,
  }) : super(key: key);

  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final ChatController _chatController = ChatController();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Color sendButtonColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _markMessagesAsRead();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _markMessagesAsRead() {
    _chatController.markAsRead(widget.roomId, widget.currentUserId);
  }

  Future<void> _sendMessage(String content,
      {MessageType type = MessageType.text, File? file}) async {
    if (content.trim().isEmpty && type == MessageType.text) return;

    try {
      await _chatController.sendMessage(
        roomId: widget.roomId,
        senderId: widget.currentUserId,
        content: content,
        type: type,
        file: file,
      );

      _controller.clear();
      setState(() {
        sendButtonColor = Colors.grey;
      });
      _scrollToBottom();
    } catch (e) {
      print('메시지 전송 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('메시지 전송 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final File imageFile = File(image.path);
        // 파일이 존재하는지 확인
        if (await imageFile.exists()) {
          await _sendMessage(
            '이미지',
            type: MessageType.image,
            file: imageFile,
          );
        } else {
          throw Exception('이미지 파일을 찾을 수 없습니다');
        }
      }
    } catch (e) {
      print('이미지 선택 오류: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFlagIcon(String countryCode) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CountryFlag.fromCountryCode(
          countryCode,
          height: 20,
          width: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "AM 01:34",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.grey[300],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: _buildFlagIcon(widget.countryCode),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "@${widget.userName.toLowerCase()}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "User_name",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Text(
            "English · 한국어",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatController.firestore
                  .collection('chatRooms/${widget.roomId}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots()
                  .map((snapshot) => snapshot.docs
                      .map((doc) => ChatMessage.fromFirestore(doc))
                      .toList()),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.currentUserId;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isMe) ...[
                            CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF477BFF)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _buildMessageContent(message),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _messageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.fileUrl != null)
              Image.network(
                message.fileUrl!,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
          ],
        );
      case MessageType.text:
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: message.senderId == widget.currentUserId
                ? Colors.white
                : Colors.black,
          ),
        );
    }
  }

  Widget _messageInputField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 28),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF477BFF)),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('이미지 보내기'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (text) {
                setState(() {
                  sendButtonColor =
                      text.isNotEmpty ? const Color(0xFF477BFF) : Colors.grey;
                });
              },
              cursorColor: const Color(0xFF477BFF),
              decoration: InputDecoration(
                hintText: "메시지를 입력하세요.",
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(CupertinoIcons.paperplane_fill, color: sendButtonColor),
            onPressed: () => _sendMessage(_controller.text),
          ),
        ],
      ),
    );
  }
}
