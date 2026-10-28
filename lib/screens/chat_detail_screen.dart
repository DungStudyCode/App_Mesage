import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/models/message_model.dart';
import 'package:app_message/models/user_model.dart';
import 'package:app_message/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final UserModel receiverUser;

  const ChatDetailScreen({super.key, required this.receiverUser});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _mesageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void _sendMessage() async {
    final text = _mesageController.text.trim();
    if (text.isEmpty) return;
    _mesageController.clear();
    await _chatService.sendMessage(
      receiverId: widget.receiverUser.uid,
      message: text,
    );
  }

  @override
  void initState() {
    super.initState();
    _chatService.markMessagesAsRead(widget.receiverUser.uid);
  }

  @override
  void dispose() {
    _mesageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        title: StreamBuilder<UserModel?>(
          stream: _chatService.getUserByIdStream(widget.receiverUser.uid),
          builder: (context, snapshot) {
            final user = snapshot.data ?? widget.receiverUser;
            final isOnline = user.isOnline;
            return Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.divider,
                  backgroundImage: user.avatarImage,
                  child: user.avatarImage == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Người dùng',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          height: 8,
                          width: 8,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppColors.online
                                : AppColors.textHint,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                          style: TextStyle(
                            fontSize: 12,
                            color: isOnline
                                ? AppColors.online
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.phone, size: 28, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.videocam, size: 35, color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: 10),
              color: AppColors.searchBar,
              child: StreamBuilder(
                stream: _chatService.getMessageStream(widget.receiverUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Chưa có tin nhắn nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  final myUid = FirebaseAuth.instance.currentUser?.uid;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == myUid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              0.75, // Tối đa 75% chiều ngang màn hình
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.myMessage : AppColors.neutralLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(color: AppColors.background),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.add_a_photo, color: AppColors.primary),
            SizedBox(width: 10),
            Icon(Icons.image, color: AppColors.primary),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _mesageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn',
                  filled: true,
                  fillColor: AppColors.primaryLight.withValues(alpha: 0.5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),
            InkWell(
              onTap: _sendMessage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 9,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Icon(
                    Icons.send,
                    color: AppColors.background,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
