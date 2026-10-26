import 'package:app_message/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Gửi lời mời kb
  Future<void> sendFriendRequest(String receiverId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null || receiverId == currentUserId) return;

    final requestId = '${currentUserId}_$receiverId';
    await _firestore.collection('friend_requests').doc(requestId).set({
      'requestId': requestId,
      'senderId': currentUserId,
      'receiverId': receiverId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Hủy/ thu hồi lời mời
  Future<void> cancelFriendRequest(String receiverId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    final requestId = '${currentUserId}_$receiverId';
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  //Chấp nhận kb
  Future<void> acceptFriendRequest(String senderId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    final requestId = '${senderId}_$currentUserId';
    // Xóa lời mời kb
    await _firestore.collection('friend_requests').doc(requestId).delete();
    // Thêm vào ds bạn bè của mình
    await _firestore.collection('user').doc(currentUserId).update({
      'friends': FieldValue.arrayUnion([senderId]),
    });
    // Thêm vào ds bạn bè của người gửi
    await _firestore.collection('user').doc(senderId).update({
      'friends': FieldValue.arrayUnion([currentUserId]),
    });
  }

  // Từ chối kb
  Future<void> declineFriendRequest(String senderId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    final requestId = '${senderId}_$currentUserId';
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  // Hủy kết bạn
  Future<void> unfriend(String friendId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;
    await _firestore.collection('user').doc(currentUserId).update({
      'friends': FieldValue.arrayRemove([friendId]),
    });
    await _firestore.collection('user').doc(friendId).update({
      'friends': FieldValue.arrayRemove([currentUserId]),
    });
  }

  // Lấy ds bn bè realtime
  Stream<List<UserModel>> getFriendsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('user')
        .doc(currentUserId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists || doc.data() == null) return [];
          final user = UserModel.fromMap(doc.data()!);
          final friendIds = user.friends;
          if (friendIds.isEmpty) return [];
          // Lấy thông tin chi tiết từng bạn bè
          final friendDocs = await Future.wait(
            friendIds.map((id) => _firestore.collection('user').doc(id).get()),
          );
          return friendDocs
              .where((d) => d.exists && d.data() != null)
              .map((d) => UserModel.fromMap(d.data()!))
              .toList();
        });
  }

  // Lấy ds lời mời kb đến
  Stream<List<UserModel>> getPendingFriendRequestsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final docs = snapshot.docs;
          if (docs.isEmpty) return [];
          // Lấy thông tin chi tiết từng người gửi
          final friendDocs = await Future.wait(
            docs.map(
              (d) => _firestore.collection('user').doc(d['senderId']).get(),
            ),
          );
          return friendDocs
              .where((d) => d.exists && d.data() != null)
              .map((d) => UserModel.fromMap(d.data()!))
              .toList();
        });
  }

  // Lấy ds lời mời kb gửi
  Stream<List<UserModel>> getPendingRequestsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('friend_requests')
        .where('receiverId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
          final senderIds = snapshot.docs
              .map((d) => d['senderId'] as String)
              .toList();
          if (senderIds.isEmpty) return [];
          final userDocs = await Future.wait(
            senderIds.map((id) => _firestore.collection('user').doc(id).get()),
          );
          return userDocs
              .where((doc) => doc.exists && doc.data() != null)
              .map((doc) => UserModel.fromMap(doc.data()!))
              .toList();
        });
  }

  Stream<List<String>> getSentRequestReceiverIdsStream() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);
    return _firestore
        .collection('friend_requests')
        .where('senderId', isEqualTo: currentUserId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((d) => d['receiverId'] as String).toList(),
        );
  }
}
