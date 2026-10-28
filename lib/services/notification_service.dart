import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/screens/chat_detail_screen.dart';
import 'package:app_message/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background handler cho Firebase Cloud Messaging
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Global key để điều hướng màn hình khi bấm vào thông báo
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Kênh thông báo Android (Mức ưu tiên cao nhất: Rung, chuông, heads-up banner)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Thông báo tin nhắn',
    description: 'Kênh nhận thông báo tin nhắn mới và cuộc gọi',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Khởi tạo toàn bộ cấu hình Notification
  Future<void> initialize() async {
    // 1. Yêu cầu quyền thông báo (bắt buộc từ Android 13 và iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'User granted notification permission: ${settings.authorizationStatus}',
    );

    // 2. Cấu hình hiển thị notification khi app ở Foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. Khởi tạo Flutter Local Notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNotificationClick(
            response.payload!,
            actionId: response.actionId,
          );
        }
      },
    );

    // 4. Tạo Notification Channel trên Android
    final androidImplementation = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_channel);
    }

    // 5. Đăng ký nhận background message
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 6. Lắng nghe tin nhắn khi app đang chạy (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Nhận FCM message foreground: ${message.notification?.title}');
      showRemoteNotification(message);
    });

    // 7. Lắng nghe khi người dùng bấm vào thông báo khi app đang ở Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Mở app từ thông báo background: ${message.data}');
      final senderId = message.data['senderId'] as String?;
      if (senderId != null) {
        navigateToChat(senderId);
      }
    });

    // 8. Kiểm tra xem app có được mở từ trạng thái bị tắt hoàn toàn (Terminated) không
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('Mở app từ trạng thái terminated: ${initialMessage.data}');
      final senderId = initialMessage.data['senderId'] as String?;
      if (senderId != null) {
        // Đợi 1 chút để UI load xong rồi điều hướng
        Future.delayed(const Duration(milliseconds: 800), () {
          navigateToChat(senderId);
        });
      }
    }

    // 9. Lắng nghe làm mới token
    _fcm.onTokenRefresh.listen((newToken) {
      updateTokenInFirestore(newToken);
    });

    // 10. Lấy token ban đầu và lưu vào Firestore
    await updateTokenInFirestore();
  }

  /// Cập nhật FCM Token của thiết bị vào tài khoản người dùng trong Firestore
  Future<void> updateTokenInFirestore([String? customToken]) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = customToken ?? await _fcm.getToken();
      if (token != null) {
        debugPrint('FCM Token hiện tại: $token');
        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
              'fcmToken': token,
              'lastTokenUpdate': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      debugPrint('Lỗi cập nhật FCM token: $e');
    }
  }

  /// Hiển thị thông báo RemoteMessage bằng Local Notifications
  void showRemoteNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      final bigTextStyle = BigTextStyleInformation(
        notification.body ?? '',
        htmlFormatBigText: true,
        contentTitle: '<b>${notification.title ?? "Tin nhắn mới"}</b>',
        htmlFormatContentTitle: true,
      );

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title ?? 'Tin nhắn mới',
        body: notification.body ?? '',
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.max,
            priority: Priority.max,
            category: AndroidNotificationCategory.message,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
            color: AppColors.primary,
            styleInformation: bigTextStyle,
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// Hiển thị thông báo hệ thống phong cách Messenger/Zalo (Màu tím, avatar, BigText, nút tương tác)
  Future<void> showLocalSystemNotification({
    required int id,
    required String title,
    required String body,
    String? senderId,
    Uint8List? avatarBytes,
  }) async {
    final Map<String, dynamic> payloadMap = {};
    if (senderId != null) {
      payloadMap['senderId'] = senderId;
    }

    Uint8List? circularBytes = avatarBytes != null
        ? await _cropToCircle(avatarBytes)
        : null;

    // Lưu avatar vào file cache để hệ thống Android load ảnh trực tiếp mượt mà
    final avatarFilePath = circularBytes != null
        ? await _saveAvatarToFile(circularBytes, 'avatar_${senderId ?? id}')
        : null;

    final person = Person(
      name: title,
      key: senderId,
      icon: avatarFilePath != null
          ? BitmapFilePathAndroidIcon(avatarFilePath)
          : (circularBytes != null
                ? ByteArrayAndroidIcon(circularBytes)
                : null),
      important: true,
    );

    // BẮT BUỘC conversationTitle: null để Android hiểu đây là chat 1-1 và hiển thị Avatar người gửi thay vì Logo App
    final messagingStyle = MessagingStyleInformation(
      person,
      conversationTitle: null,
      groupConversation: false,
      messages: [Message(body, DateTime.now(), person)],
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          color: AppColors.primary,
          // Đặt avatar tròn làm largeIcon cho thông báo
          largeIcon: avatarFilePath != null
              ? FilePathAndroidBitmap(avatarFilePath)
              : (circularBytes != null
                    ? ByteArrayAndroidBitmap(circularBytes)
                    : null),
          styleInformation: messagingStyle,
          playSound: true,
          enableVibration: true,
          ticker: '$title: $body',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payloadMap),
    );
  }

  /// Xử lý sự kiện khi bấm vào thông báo hoặc nút hành động (Trả lời / Đã xem)
  void _handleNotificationClick(String payload, {String? actionId}) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final senderId = data['senderId'] as String?;
      if (senderId == null) return;

      if (actionId == 'mark_as_read') {
        // Đánh dấu đã đọc cuộc trò chuyện
        ChatService().markMessagesAsRead(senderId);
      } else {
        // 'reply_action' hoặc bấm trực tiếp vào thông báo -> mở màn hình chat
        navigateToChat(senderId);
      }
    } catch (e) {
      debugPrint('Lỗi giải mã payload thông báo: $e');
    }
  }

  /// Điều hướng người dùng thẳng tới màn hình Chat của người gửi
  Future<void> navigateToChat(String senderId) async {
    final sender = await ChatService().getUserById(senderId);
    if (sender != null && navigatorKey.currentState != null) {
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(receiverUser: sender),
        ),
      );
    }
  }

  /// Cắt ảnh đại diện thành hình tròn hoàn hảo để hiển thị trên khay thông báo Android
  static Future<Uint8List?> _cropToCircle(
    Uint8List bytes, {
    int size = 240,
  }) async {
    try {
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: size,
        targetHeight: size,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..isAntiAlias = true;

      final rect = Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
      canvas.clipPath(Path()..addOval(rect));

      final src = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );
      canvas.drawImageRect(image, src, rect, paint);

      final picture = recorder.endRecording();
      final circularImage = await picture.toImage(size, size);
      final byteData = await circularImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Lỗi crop circular avatar: $e');
      return bytes;
    }
  }

  /// Lưu file avatar vào bộ nhớ đệm (cache) để Android NotificationManager load trực tiếp
  static Future<String?> _saveAvatarToFile(
    Uint8List bytes,
    String filename,
  ) async {
    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/$filename.png');
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (e) {
      debugPrint('Lỗi lưu avatar file: $e');
      return null;
    }
  }
}
