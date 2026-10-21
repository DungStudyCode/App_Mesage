import 'package:app_message/utils/validators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Đăng nhập thất bại';
    } catch (e) {
      throw 'Đã xảy ra lỗi, vui lòng thử lại sau';
    }
  }

  //Đăng xuẩt
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
