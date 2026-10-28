import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/models/user_model.dart';
import 'package:app_message/screens/chat_detail_screen.dart';
import 'package:app_message/services/auth_service.dart';
import 'package:app_message/services/chat_service.dart';
import 'package:app_message/services/friend_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(child: Icon(Icons.message)),
                SizedBox(width: 10),
                Text(
                  'Tin nhắn',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textHint),
                    SizedBox(width: 10),
                    Text(
                      'Tìm kiếm cuộc trò chuyện, bạn bè...',
                      style: TextStyle(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Thanh cuộn ngang Bạn bè Realtime
            SizedBox(
              height: 95,
              child: StreamBuilder<List<UserModel>>(
                stream: FriendService().getFriendsStream(),
                builder: (context, snapshot) {
                  final myFriends = snapshot.data ?? [];

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: myFriends.length + 1,
                    itemBuilder: (context, index) {
                      // Vị trí đầu tiên (index = 0): Ghi chú của tôi
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 14.0),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  StreamBuilder<UserModel?>(
                                    stream: AuthService().getUserDataStream(),
                                    builder: (context, userSnapshot) {
                                      final myUser = userSnapshot.data;
                                      return CircleAvatar(
                                        radius: 32,
                                        backgroundColor: AppColors.divider,
                                        backgroundImage: myUser?.avatarImage,
                                        child: myUser?.avatarImage == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 36,
                                                color: AppColors.textSecondary,
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Ghi chú',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Các vị trí tiếp theo: Bạn bè thật
                      final user = myFriends[index - 1];
                      return _buildOnlineUserItem(context, user);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider, thickness: 1),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: ChatService().getChatRoomsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = List<QueryDocumentSnapshot>.from(
                    snapshot.data?.docs ?? [],
                  );

                  // Sắp xếp tin nhắn mới nhất lên đầu (Client-side)
                  docs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = aData['lastMessageTime'] as Timestamp?;
                    final bTime = bData['lastMessageTime'] as Timestamp?;
                    if (aTime == null && bTime == null) return 0;
                    if (aTime == null) return 1;
                    if (bTime == null) return -1;
                    return bTime.compareTo(aTime);
                  });

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Chưa có cuộc trò chuyện nào",
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final roomData =
                          docs[index].data() as Map<String, dynamic>;
                      final participantIds = List<String>.from(
                        roomData['participants'] ?? [],
                      );
                      final otherUserId = participantIds.firstWhere(
                        (uid) => uid != currentUserId,
                        orElse: () => '',
                      );
                      if (otherUserId.isEmpty) return const SizedBox.shrink();

                      return StreamBuilder<UserModel?>(
                        stream: ChatService().getUserByIdStream(otherUserId),
                        builder: (context, userSnapshot) {
                          final otherUser = userSnapshot.data;
                          // Nếu là tài khoản chưa có trong collection user (ví dụ demo) thì tạo fallback
                          final targetUser =
                              otherUser ??
                              UserModel(
                                uid: otherUserId,
                                name: otherUserId == 'receiver_demo_id'
                                    ? 'Nguyễn Tiến Dũng (Demo)'
                                    : 'Người dùng',
                                account: '',
                                authEmail: '',
                                avatarUrl: '',
                              );

                          final displayName = targetUser.name;
                          final lastMessage = roomData['lastMessage'] ?? '';
                          final lastTime =
                              roomData['lastMessageTime'] as Timestamp?;
                          final timeStr = lastTime != null
                              ? '${lastTime.toDate().hour.toString().padLeft(2, '0')}:${lastTime.toDate().minute.toString().padLeft(2, '0')}'
                              : '';
                          final isOnline = targetUser.isOnline;
                          final myUid = FirebaseAuth.instance.currentUser?.uid;
                          final lastSenderId = roomData['lastMessageSenderId'];
                          final bool isRoomRead =
                              roomData['isRead'] as bool? ?? false;
                          final unreadMap =
                              roomData['unreadCounts'] as Map<String, dynamic>?;
                          final int unreadCount =
                              (unreadMap?[myUid] as num?)?.toInt() ?? 0;
                          final bool isUnread = unreadCount > 0;
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailScreen(
                                    receiverUser: targetUser,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  // Avatar + Chấm online
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: AppColors.divider,
                                        backgroundImage: targetUser.avatarImage,
                                        child: targetUser.avatarImage == null
                                            ? const Icon(
                                                Icons.person,
                                                size: 32,
                                                color: AppColors.primary,
                                              )
                                            : null,
                                      ),
                                      if (isOnline)
                                        Positioned(
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                            height: 14,
                                            width: 14,
                                            decoration: BoxDecoration(
                                              color: AppColors.online,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  // Tên & Tin nhắn cuối
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          lastMessage.isNotEmpty
                                              ? (lastSenderId == myUid)
                                                    ? 'Bạn: $lastMessage'
                                                    : lastMessage
                                              : 'Đã bắt đầu cuộc trò chuyện',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isUnread
                                                ? AppColors.textPrimary
                                                : AppColors.textSecondary,
                                            fontWeight: isUnread
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Cột bên phải: Thời gian & Chấm thông báo chưa đọc
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          color: isUnread
                                              ? AppColors.primary
                                              : AppColors.textHint,
                                          fontSize: 12,
                                          fontWeight: isUnread
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      // Cột bên phải: Trạng thái tin nhắn
                                      // 1. Nếu là tin nhắn do mình gửi đi:
                                      //    - Đối phương đã xem (isRoomRead): Hiện avatar tròn nhỏ của đối phương (giống Messenger)
                                      //    - Chưa xem: Hiện icon tích tròn xám
                                      if (lastSenderId == myUid) ...[
                                        if (isRoomRead)
                                          CircleAvatar(
                                            radius: 8,
                                            backgroundColor: AppColors.divider,
                                            backgroundImage:
                                                targetUser.avatarImage,
                                            child:
                                                targetUser.avatarImage == null
                                                ? const Icon(
                                                    Icons.person,
                                                    size: 10,
                                                    color: AppColors.primary,
                                                  )
                                                : null,
                                          )
                                        else
                                          const Icon(
                                            Icons.done_all,
                                            size: 16,
                                            color: AppColors.textHint,
                                          ),
                                      ] else ...[
                                        // 2. Nếu là tin nhắn từ đối phương gửi đến:
                                        if (unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              unreadCount > 99
                                                  ? '99+'
                                                  : '$unreadCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm rút gọn tên thông minh (Ví dụ: "Nguyễn Văn Dũng" -> "Văn Dũng")
  String _getShortName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return fullName;
    return '${parts[parts.length - 2]} ${parts.last}';
  }

  Widget _buildOnlineUserItem(BuildContext context, UserModel user) {
    return StreamBuilder<UserModel?>(
      stream: ChatService().getUserByIdStream(user.uid),
      builder: (context, snapshot) {
        final liveUser = snapshot.data ?? user;
        final isOnline = liveUser.isOnline;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(receiverUser: liveUser),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.divider,
                      backgroundImage: liveUser.avatarImage,
                      child: liveUser.avatarImage == null
                          ? const Icon(
                              Icons.person,
                              size: 36,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: isOnline
                              ? AppColors.online
                              : AppColors.textHint,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 74,
                  child: Text(
                    liveUser.name.isNotEmpty
                        ? _getShortName(liveUser.name)
                        : 'Người dùng',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
