import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserModel {
  final String uid;
  final String name;
  final String account;
  final String authEmail;
  final String avatarUrl;
  final bool isOnline;
  final List<String> friends;
  final DateTime? createdAt;
  final DateTime? lastActive;
  final String? fcmToken;

  UserModel({
    required this.uid,
    required this.name,
    required this.account,
    required this.authEmail,
    required this.avatarUrl,
    this.isOnline = false,
    this.createdAt,
    this.lastActive,
    this.friends = const [],
    this.fcmToken,
  });

  // Lấy dữ liệu về từ Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      account: map['account'] ?? '',
      authEmail: map['authEmail'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      isOnline: map['isOnline'] ?? false,
      friends: List<String>.from(map['friends'] ?? []),
      fcmToken: map['fcmToken'] as String?,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
    );
  }

  // Chuyển về Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'account': account,
      'authEmail': authEmail,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'friends': friends,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'lastActive': lastActive != null
          ? Timestamp.fromDate(lastActive!)
          : null,
    };
  }

  // Tạo bản sao cập nhật
  UserModel copyWith({
    String? uid,
    String? name,
    String? account,
    String? authEmail,
    String? avatarUrl,
    bool? isOnline,
    List<String>? friends,
    DateTime? createdAt,
    DateTime? lastActive,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      account: account ?? this.account,
      authEmail: authEmail ?? this.authEmail,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      friends: friends ?? this.friends,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  String get displayAccount {
    // 1. Nếu account có dữ liệu thì ưu tiên hiển thị account
    if (account.isNotEmpty) {
      return account;
    }
    // 2. Nếu authEmail chứa đuôi ảo @appmessage.com thì cắt bỏ lấy lại SĐT
    if (authEmail.endsWith('@appmessage.com')) {
      return authEmail.replaceAll('@appmessage.com', '');
    }
    return authEmail;
  }

  // 👇 Thêm getter này để kiểm tra và tạo ImageProvider
  // Tự động nhận diện link web hoặc ảnh Base64
  ImageProvider? get avatarImage {
    if (avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('http')) {
      return NetworkImage(avatarUrl);
    }
    try {
      final cleanBase64 = avatarUrl.contains(',')
          ? avatarUrl.split(',').last
          : avatarUrl;
      return MemoryImage(base64Decode(cleanBase64));
    } catch (_) {
      return null;
    }
  }
}
