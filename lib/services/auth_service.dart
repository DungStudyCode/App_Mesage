import 'dart:convert';

import 'package:app_message/models/user_model.dart';
import 'package:app_message/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential?> signUp({
    required String name,
    required String account,
    required String password,
  }) async {
    try {
      //Đổi sđt sang mail ảo
      String authEmail = account;
      if (Validators.isPhoneNumber(account)) {
        authEmail = '$account@appmessage.com';
      }

      // tạo tài khoản trên firebase
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: authEmail, password: password);

      // Cập nhật hiển thị tên lên firebase
      await userCredential.user?.updateDisplayName(name);
      // lưu thông tin
      String uid = userCredential.user!.uid;
      await _firestore.collection('user').doc(uid).set({
        'uid': uid,
        'name': name,
        'account': account,
        'authEmail': authEmail,
        'isOnline': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Đăng kí thất bại';
    } catch (e) {
      throw 'Đã xảy ra lỗi, vui lòng đăng kí lại sau';
    }
  }

  // đăng nhập
  Future<UserCredential?> signIn({
    required String account,
    required String password,
  }) async {
    try {
      // chuẩn hóa sdt thành email
      String authEmail = account;
      if (Validators.isPhoneNumber(account)) {
        authEmail = '$account@appmessage.com';
      }
      // đăng nhập với firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: authEmail,
        password: password,
      );
      await updateOnlineStatus(true);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Đăng nhập thất bại';
    } catch (e) {
      throw 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }

  //Đăng xuẩt
  Future<void> signOut() async {
    await updateOnlineStatus(false);
    await _auth.signOut();
  }

  //lắng nghe dữ liệu theo theo thời gian thực
  Stream<UserModel?> getUserDataStream() {
    // Lấy id ng dùng
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore.collection('user').doc(user.uid).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  // Cập nhật trạng thái online / offline
  Future<void> updateOnlineStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('user').doc(user.uid).set({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<String?> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    // 1. Mở thư viện ảnh
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 250,
      maxHeight: 250,
      imageQuality: 60,
    );
    if (pickedFile == null) return null;
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    // Chuyển dữ liệu thành chuối Base64
    final bytes = await pickedFile.readAsBytes();
    final base64String = base64Encode(bytes);

    // Lưu chuỗi vào fire
    await _firestore.collection('user').doc(uid).update({
      'avatarUrl': base64String,
    });
    return base64String;
  }
}
