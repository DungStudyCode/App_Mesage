import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/models/user_model.dart';
import 'package:app_message/screens/chat_detail_screen.dart';
import 'package:app_message/services/auth_service.dart';
import 'package:app_message/services/chat_service.dart';
import 'package:app_message/services/friend_service.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  final ChatService _chatService = ChatService();

  String _searchQuery = '';
  int _selectedFilter =
      0; // 0: Tất cả bạn bè, 1: Đang hoạt động, 2: Ngoại tuyến

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Map<String, List<UserModel>> _groupFriendsByAlphabet(
    List<UserModel> friends,
  ) {
    final sortedList = List<UserModel>.from(friends)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    final Map<String, List<UserModel>> grouped = {};

    for (var friend in sortedList) {
      if (friend.name.isEmpty) continue;
      final firstLetter = friend.name.trim().characters.first.toUpperCase();
      grouped.putIfAbsent(firstLetter, () => []).add(friend);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: const Text(
          'Bạn bè',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Nút tròn thêm bạn bè góc phải
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {
                // Focus vào ô tìm kiếm hoặc mở dialog thêm bạn
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_alt_1,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // 1. Ô tìm kiếm bo tròn 50px
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.neutralLight,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm bạn bè theo tên hoặc email...',
                  hintStyle: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.textHint),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 2. Nội dung hiển thị
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // Giao diện khi người dùng gõ tìm kiếm người mới
  Widget _buildSearchResults() {
    return StreamBuilder<UserModel?>(
      stream: AuthService().getUserDataStream(),
      builder: (context, myUserSnapshot) {
        final myFriends = myUserSnapshot.data?.friends ?? [];

        return StreamBuilder<List<String>>(
          stream: _friendService.getSentRequestReceiverIdsStream(),
          builder: (context, sentReqSnapshot) {
            final sentIds = sentReqSnapshot.data ?? [];

            return StreamBuilder<List<UserModel>>(
              stream: _chatService.getAllUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allUsers = snapshot.data ?? [];
                final searchResults = allUsers.where((u) {
                  return u.name.toLowerCase().contains(_searchQuery) ||
                      u.account.toLowerCase().contains(_searchQuery);
                }).toList();

                if (searchResults.isEmpty) {
                  return Center(
                    child: Text(
                      'Không tìm thấy người dùng phù hợp',
                      style: TextStyle(color: AppColors.textHint, fontSize: 15),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final user = searchResults[index];
                    final isFriend = myFriends.contains(user.uid);
                    final isSent = sentIds.contains(user.uid);

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.divider,
                        child: user.avatarImage == null
                            ? const Icon(Icons.person, color: AppColors.primary)
                            : null,
                      ),
                      title: Text(
                        user.name.isNotEmpty ? user.name : 'Người dùng',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        user.account,
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: isFriend
                          ? ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChatDetailScreen(receiverUser: user),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.chat, size: 16),
                              label: const Text('Nhắn tin'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            )
                          : isSent
                          ? OutlinedButton(
                              onPressed: () async {
                                await _friendService.cancelFriendRequest(
                                  user.uid,
                                );
                              },
                              child: const Text('Đã gửi lời mời'),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                await _friendService.sendFriendRequest(
                                  user.uid,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Kết bạn'),
                            ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Giao diện chính theo thiết kế: Filter Chips + Card Lời mời + Phân nhóm Alphabet
  Widget _buildMainContent() {
    return StreamBuilder<List<UserModel>>(
      stream: _friendService.getPendingFriendRequestsStream(),
      builder: (context, requestSnapshot) {
        final pendingRequests = requestSnapshot.data ?? [];

        return StreamBuilder<List<UserModel>>(
          stream: _friendService.getFriendsStream(),
          builder: (context, friendsSnapshot) {
            if (friendsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allFriends = friendsSnapshot.data ?? [];
            final onlineFriends = allFriends.where((u) => u.isOnline).toList();
            final offlineFriends = allFriends
                .where((u) => !u.isOnline)
                .toList();

            // Danh sách được chọn theo Filter (0: Tất cả, 1: Online, 2: Offline)
            final displayFriends = _selectedFilter == 0
                ? allFriends
                : _selectedFilter == 1
                ? onlineFriends
                : offlineFriends;
            final groupedFriends = _groupFriendsByAlphabet(displayFriends);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 1. Thanh Filter Chips (Tất cả / Đang hoạt động / Ngoại tuyến)
                _buildFilterChips(
                  totalCount: allFriends.length,
                  onlineCount: onlineFriends.length,
                  offlineCount: offlineFriends.length,
                ),
                const SizedBox(height: 16),

                // 2. Card Lời mời kết bạn nổi bật (chỉ hiện khi có lời mời)
                if (pendingRequests.isNotEmpty) ...[
                  _buildPendingRequestCard(pendingRequests.first),
                  const SizedBox(height: 16),
                ],

                // 3. Danh sách bạn bè gom nhóm theo Alphabet
                if (displayFriends.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        _selectedFilter == 1
                            ? 'Hiện không có bạn bè nào đang hoạt động'
                            : _selectedFilter == 2
                            ? 'Không có bạn bè nào ngoại tuyến'
                            : 'Chưa có bạn bè nào',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...groupedFriends.entries.map((entry) {
                    final letter = entry.key;
                    final list = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header chữ cái (ví dụ: B - 1 bạn)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(
                                alpha: .2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  letter,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  '${list.length} bạn',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textHint,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Danh sách bạn bè trong nhóm chữ cái
                        ...list.map((friend) => _buildFriendRow(friend)),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
              ],
            );
          },
        );
      },
    );
  }

  // 1. Thanh Filter Chips ngang
  Widget _buildFilterChips({
    required int totalCount,
    required int onlineCount,
    required int offlineCount,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Chip: Tất cả bạn bè
          _buildChip(
            label: 'Tất cả bạn bè ($totalCount)',
            isSelected: _selectedFilter == 0,
            onTap: () => setState(() => _selectedFilter = 0),
          ),
          const SizedBox(width: 8),

          // Chip: Đang hoạt động
          _buildChip(
            label: 'Đang hoạt động ($onlineCount)',
            isSelected: _selectedFilter == 1,
            showOnlineDot: true,
            onTap: () => setState(() => _selectedFilter = 1),
          ),
          const SizedBox(width: 8),

          // Chip: Ngoại tuyến
          _buildChip(
            label: 'Ngoại tuyến ($offlineCount)',
            isSelected: _selectedFilter == 2,
            onTap: () => setState(() => _selectedFilter = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool showOnlineDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.neutralLight,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showOnlineDot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.online,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Card Lời mời kết bạn ghim trên đầu
  Widget _buildPendingRequestCard(UserModel sender) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.neutralLight,
            backgroundImage: sender.avatarUrl.isNotEmpty
                ? NetworkImage(sender.avatarUrl)
                : null,
            child: sender.avatarUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),

          // Tên + Nút
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sender.name.isNotEmpty ? sender.name : 'Người dùng',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Lời mời mới',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  sender.authEmail.isNotEmpty
                      ? sender.authEmail
                      : sender.account,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Nút Đồng ý
                    ElevatedButton(
                      onPressed: () async {
                        await _friendService.acceptFriendRequest(sender.uid);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Đồng ý',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Nút Xóa
                    ElevatedButton(
                      onPressed: () async {
                        await _friendService.declineFriendRequest(sender.uid);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neutralLight,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Dòng hiển thị bạn bè với nút nhắn tin squircle
  Widget _buildFriendRow(UserModel friend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(receiverUser: friend),
            ),
          );
        },
        child: Row(
          children: [
            // Avatar có chấm xanh online
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.neutralLight,
                  backgroundImage: friend.avatarImage,
                  child: friend.avatarImage == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                if (friend.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 13,
                      width: 13,
                      decoration: BoxDecoration(
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Tên và thông tin phụ
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.name.isNotEmpty ? friend.name : 'Người dùng',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    friend.displayAccount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Nút nhắn tin nhanh
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatDetailScreen(receiverUser: friend),
                  ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
