import 'package:flutter/material.dart';
import '../controllers/chat_controller.dart';

class CreateChatScreen extends StatefulWidget {
  final String currentUserId;
  final List<String> availableUsers;

  const CreateChatScreen({
    Key? key,
    required this.currentUserId,
    required this.availableUsers,
  }) : super(key: key);

  @override
  _CreateChatScreenState createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final TextEditingController _nameController = TextEditingController();
  final Set<String> _selectedUsers = {};
  bool _isGroup = false;

  @override
  void initState() {
    super.initState();
    _selectedUsers.add(widget.currentUserId);
  }

  Future<void> _createChat() async {
    if (_selectedUsers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('최소 1명의 사용자를 선택해주세요')),
      );
      return;
    }

    if (_isGroup && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('그룹 이름을 입력해주세요')),
      );
      return;
    }

    final chatController = ChatController();
    final roomId = await chatController.createChatRoom(
      name: _isGroup ? _nameController.text : _selectedUsers.first,
      participants: _selectedUsers.toList(),
      isGroup: _isGroup,
    );

    if (mounted) {
      Navigator.pop(context, roomId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isGroup ? '그룹 채팅 만들기' : '개인 채팅 만들기'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('그룹 채팅'),
            value: _isGroup,
            onChanged: (value) {
              setState(() {
                _isGroup = value;
              });
            },
          ),
          if (_isGroup)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '그룹 이름',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.availableUsers.length,
              itemBuilder: (context, index) {
                final user = widget.availableUsers[index];
                if (user == widget.currentUserId)
                  return const SizedBox.shrink();

                return CheckboxListTile(
                  title: Text(user),
                  value: _selectedUsers.contains(user),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedUsers.add(user);
                      } else {
                        _selectedUsers.remove(user);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createChat,
        child: const Icon(Icons.check),
      ),
    );
  }
}
