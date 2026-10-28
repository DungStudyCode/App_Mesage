import 'package:app_message/models/message_model.dart';
import 'package:app_message/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo phòng chat
  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  // Gửi tin nhắn
  Future<void> sendMessage({
    required String receiverId,
    required String message,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || message.trim().isEmpty) return;
    final String senderId = currentUser.uid;
    final String chatRoomId = getChatRoomId(senderId, receiverId);
    final DateTime now = DateTime.now();
    //Tạo đối tượng MessageModel
    final newMassage = MessageModel(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: now,
      isRead: false,
    );
    //Lưu vào Firebase
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMassage.toMap());

    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'participants': [senderId, receiverId],
      'lastMessage': message.trim(),
      'lastMessageSenderId': senderId,
      'lastMessageTime': Timestamp.fromDate(now),
      'isRead': false,
      'unreadCounts': {receiverId: FieldValue.increment(1), senderId: 0},
    }, SetOptions(merge: true));
  }

  // realtime tin nhăn
  Stream<List<MessageModel>> getMessageStream(String receiverId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return Stream.value([]);
    final String chatRoomId = getChatRoomId(currentUser.uid, receiverId);

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromMap(doc.data()))
              .toList(),
        );
  }

  Stream<QuerySnapshot> getChatRoomsStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots();
  }

  Stream<UserModel?> getUserByIdStream(String uid) {
    return _firestore.collection('user').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  // Lấy danh sách tất cả người dùng (loại trừ tài khoản hiện tại)
  Stream<List<UserModel>> getAllUsersStream() {
    final currentUserId = _auth.currentUser?.uid;
    return _firestore.collection('user').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Đánh dấu tin nhắn đã đọc
  Future<void> markMessagesAsRead(String receiverId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;
    final chatRoomId = getChatRoomId(currentUser.uid, receiverId);
    // lấy thông tin phòng chat
    final roomDoc = await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .get();
    if (!roomDoc.exists) return;
    final data = roomDoc.data();
    final lastSenderId = data?['lastMessageSenderId'];

    if (lastSenderId != null && lastSenderId != currentUser.uid) {
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'isRead': true,
        'unreadCounts.${currentUser.uid}': 0,
      });
    }
  }

  // lấy thông tin user theo uid
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('user').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(doc.data()!);
    } catch (e) {
      return null;
    }
  }
}
