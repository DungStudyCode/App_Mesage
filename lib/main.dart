import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_message/constants/app_colors.dart';
import 'package:app_message/screens/friends_screen.dart';
import 'package:app_message/screens/home_screen.dart';
import 'package:app_message/screens/login_screen.dart';
import 'package:app_message/screens/settings_screen.dart';
import 'package:app_message/services/auth_service.dart';
import 'package:app_message/services/chat_service.dart';
import 'package:app_message/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NotificationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'App tin nhắn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const MyHomePage(title: 'App tin nhắn');
          }
          return const LoginScreen();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // Tạo biến để hiển thị vị trí trang
  int _selectedIndex = 0;

  StreamSubscription? _chatRoomsSubscription;
  final DateTime _appStartTime = DateTime.now();
  DateTime _lastNotifiedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    //lắng nghe sự kiện đóng mở app
    WidgetsBinding.instance.addObserver(this);
    //Vừa vào app đặt online & đồng bộ FCM Token
    AuthService().updateOnlineStatus(true);
    NotificationService().updateTokenInFirestore();
    _startListeningForMessages();
  }

  void _startListeningForMessages() {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    _chatRoomsSubscription = ChatService().getChatRoomsStream().listen((
      QuerySnapshot snapshot,
    ) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data == null) continue;
          final lastSenderId = data['lastMessageSenderId'] as String?;
          final lastMessage = data['lastMessage'] as String? ?? '';
          final lastTime = (data['lastMessageTime'] as Timestamp?)?.toDate();
          if (lastSenderId != null &&
              lastSenderId != currentUserId &&
              lastTime != null &&
              lastTime.isAfter(_appStartTime) &&
              lastTime.isAfter(_lastNotifiedTime)) {
            _lastNotifiedTime = lastTime;
            final sender = await ChatService().getUserById(lastSenderId);
            if (sender != null) {
              Uint8List? avatarBytes;
              if (sender.avatarUrl.isNotEmpty && !sender.avatarUrl.startsWith('http')) {
                try {
                  final cleanBase64 = sender.avatarUrl.contains(',')
                      ? sender.avatarUrl.split(',').last
                      : sender.avatarUrl;
                  avatarBytes = base64Decode(cleanBase64);
                } catch (_) {}
              }

              // 1. Luôn kích hoạt thông báo hệ thống phong cách Messenger (Màu tím, avatar tròn, BigText)
              NotificationService().showLocalSystemNotification(
                id: lastTime.millisecondsSinceEpoch ~/ 1000,
                title: sender.name,
                body: lastMessage,
                senderId: sender.uid,
                avatarBytes: avatarBytes,
              );
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Xử lý trạng thái online/offline khi app được mở/tắt
    // resumes: App được mở lên hoặc quay lại từ nền
    if (state == AppLifecycleState.resumed) {
      // khi quay lại mở app sẽ online
      AuthService().updateOnlineStatus(true);
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Khi app bị ẩn đi hoặc tắt hoàn toàn
      AuthService().updateOnlineStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Danh sách các màn hình của app đặt trong build để Hot Reload nhận diện ngay
    final List<Widget> pages = [
      const HomeScreen(),
      const FriendScreen(),
      const SettingScreen(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Tin nhắn'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Bạn bè'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.surface,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
      body: pages[_selectedIndex],
    );
  }
}
