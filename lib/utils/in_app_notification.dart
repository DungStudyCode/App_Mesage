import 'dart:async';

import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/models/user_model.dart';
import 'package:app_message/services/notification_service.dart';
import 'package:flutter/material.dart';

class InAppNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext? context, {
    dynamic sender,
    String? senderName,
    required String message,
    VoidCallback? onTap,
  }) {
    // Nếu đang có thông báo cũ thì xóa đi
    _currentEntry?.remove();
    _currentEntry = null;

    final targetContext =
        context ?? NotificationService.navigatorKey.currentContext;
    if (targetContext == null) return;

    final overlay = Overlay.maybeOf(targetContext);
    if (overlay == null) return;

    UserModel? senderUser;
    String name = 'Tin nhắn mới';
    ImageProvider? avatar;

    if (sender is UserModel) {
      senderUser = sender;
      name = sender.name.isNotEmpty ? sender.name : name;
      avatar = sender.avatarImage;
    } else if (sender is String) {
      name = sender;
    } else if (senderName != null) {
      name = senderName;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        sender: senderUser,
        senderName: name,
        avatarImage: avatar,
        message: message,
        onTap: () {
          entry.remove();
          _currentEntry = null;
          if (onTap != null) onTap();
        },
        onDismiss: () {
          entry.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }
}

class _NotificationBanner extends StatefulWidget {
  final UserModel? sender;
  final String senderName;
  final ImageProvider? avatarImage;
  final String message;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    this.sender,
    required this.senderName,
    this.avatarImage,
    required this.message,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Hiệu ứng trượt từ trên xuống trong 350ms
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0), // Bắt đầu ở ngoài màn hình phía trên
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Tự động đóng sau 4 giây
    _dismissTimer = Timer(const Duration(seconds: 4), () {
      _close();
    });
  }

  void _close() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Dismissible(
            key: const Key('in_app_noti'),
            direction: DismissDirection.up, // Cho phép vuốt lên để đóng nhanh
            onDismissed: (_) => widget.onDismiss(),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.divider),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar người gửi
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.divider,
                      backgroundImage: widget.avatarImage,
                      child: widget.avatarImage == null
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Tên & Nội dung tin nhắn
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.senderName.isNotEmpty
                                    ? widget.senderName
                                    : 'Tin nhắn mới',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Vừa xong',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textHint,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
