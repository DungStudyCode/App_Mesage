import 'package:app_message/constants/app_colors.dart';
import 'package:flutter/material.dart';

class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Danh sách bạn bè',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.person_add,
                color: AppColors.myMessage,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            //Thanh tìm kiếm
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
                      'Tìm kiếm bạn bè theo tên hoặc số điện thoại',
                      style: TextStyle(color: AppColors.textHint),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            //Danh sách bộ lọc danh sách bạn bè
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Tất cả bạn bè
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Text(
                        'Tất cả bạn bè (24)',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  //Đang hoạt động
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.otherMessage,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 13, color: AppColors.online),
                          SizedBox(width: 5),
                          Text(
                            'Đang hoạt động (8)',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  // Không hoạt động
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.otherMessage,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 13,
                            color: AppColors.textHint,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Không hoạt động (16)',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Tiêu đề Lời mời kết bạn
            Text(
              'LỜI MỜI KẾT BẠN (1)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            SizedBox(height: 8),
            // Cụm Xác nhận kết bạn
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppColors.otherMessage.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 10),
                  // Tên + Thông tin
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lê Hoàng Nam',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '3 bạn chung',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: ' • ',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                ),
                              ),
                              TextSpan(
                                text: 'Designer',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.primary,
                              ),
                              child: Text(
                                'Đồng ý',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.textHint.withValues(alpha: .2),
                              ),
                              child: Text(
                                'Xóa',
                                style: TextStyle(
                                  color: AppColors.neutral,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  // Thời gian gửi lời mời
                  Text(
                    '12m trước',
                    style: TextStyle(color: AppColors.textHint, fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            // Tiêu đề Danh sách bạn bè (cố định, không cuộn)
            Text(
              'DANH SÁCH BẠN BÈ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral,
              ),
            ),
            SizedBox(height: 8),
            // Danh sách bạn bè (cuộn)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chữ A và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'A',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '3 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nguyễn Tiến Dũng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0987654321',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'IT',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Chữ B và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'B',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bảo Long',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0905 111 222',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'IT Support',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Chữ C và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'C',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '1 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Cẩm Tú',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0966 777 888',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Sales',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Chữ D và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'D',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duy Mạnh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0911 222 333',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Mobile Dev',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Chữ H và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'H',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '2 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hoàng Nam',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0944 555 666',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Backend Dev',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    // Chữ T và số lượng bạn bè
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'T',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '3 người bạn',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Thông tin bạn bè
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.otherMessage.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  bottom: 2,
                                  child: Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tiến Dũng',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '0987 654 321',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' • ',
                                          style: TextStyle(
                                            color: AppColors.textHint,
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Flutter Dev',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            //Thời gian ngừng hoạt động
                            Icon(Icons.message, color: AppColors.textHint),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
