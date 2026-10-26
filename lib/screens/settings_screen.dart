import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/models/user_model.dart';
import 'package:app_message/screens/login_screen.dart';
import 'package:app_message/services/auth_service.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cài đặt',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Icon(Icons.search, size: 30),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cụm avatar
            StreamBuilder<UserModel?>(
              stream: AuthService().getUserDataStream(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 50),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final user = snapshot.data;
                final displayName = (user != null && user.name.isNotEmpty)
                    ? user.name
                    : 'Người dùng';
                final account = user?.account ?? "";
                final isOnline = user?.isOnline ?? false;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.background,
                                backgroundImage: user?.avatarImage,
                                child: user?.avatarImage == null
                                    ? Icon(
                                        Icons.person,
                                        size: 70,
                                        color: AppColors.primary,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đang tải lên...')),
                                  );
                                  await AuthService().pickAndUploadAvatar();
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          account,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 20),

                        // Cụm trạng thái có thể bấm để chuyển đổi realtime
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await AuthService().updateOnlineStatus(!isOnline);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isOnline
                                  ? AppColors.online.withValues(alpha: 0.15)
                                  : AppColors.textSecondary.withValues(
                                      alpha: 0.15,
                                    ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isOnline
                                    ? AppColors.online.withValues(alpha: 0.3)
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: isOnline
                                      ? AppColors.online
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOnline ? 'Đang trực tuyến' : 'Ngoại tuyến',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isOnline
                                        ? AppColors.online
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // Cụm Tài khoản, tùy chọn
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TÀI KHOẢN & TÙY CHỌN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Chỉnh sửa thông tin cá nhân',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(color: AppColors.divider, thickness: 1),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.badge.withValues(
                              alpha: 0.8,
                            ),
                            child: Icon(
                              Icons.notifications,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Thông báo & âm thanh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.toggle_on,
                              size: 50,
                              color: AppColors.myMessage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Cụm bảo mật hệ thống
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BẢO MẬT & HỆ THỐNG',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Đổi mật khẩu
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.online,
                            child: Icon(
                              Icons.lock_outline,
                              size: 24,
                              color: AppColors.neutralLight,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Đổi mật khẩu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.divider, thickness: 1),

                      // Quyền riêng tư & Mã hoá
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.myMessage,
                            child: Icon(
                              Icons.shield_outlined,
                              size: 24,
                              color: AppColors.neutralLight,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Quyền riêng tư & Mã hoá',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Divider(color: AppColors.divider, thickness: 1),
                      // Đăng xuất
                      InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text('Đăng xuất'),
                              content: Text('Bạn có chắc chắn muốn đăng xuất'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(dialogContext);
                                  },
                                  child: Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    await AuthService().signOut();
                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  },

                                  child: Text('Đăng xuất'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.badge,
                              child: Icon(
                                Icons.logout,
                                size: 24,
                                color: AppColors.neutralLight,
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.badge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Text(
                'Phiên bản 1.0.0',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
