import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Gửi mã OTP về Số điện thoại
  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(FirebaseAuthException) onVerifyFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: onVerifyFailed,
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 2. Xác nhận OTP và Đăng nhập
  Future<UserCredential> signInWithOtp(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // Đăng nhập Email/Pass hiện có
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Đăng ký tài khoản mới + tự động tạo user document phân quyền
  Future<UserCredential> signUp(String email, String password, {String? name}) async {
    try {
      // 1. Tạo tài khoản Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2. Phân quyền tự động: nếu là người của công ty thì làm admin, còn lại là customer
      String role = 'customer';
      if (email.endsWith('@ebony.com') || email == 'admin@ebony.com') {
        role = 'admin';
      }

      // 3. Đẩy thông tin đầy đủ lên collection 'users'
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name ?? email.split('@')[0],
        'phone': '',
        'role': role,
        'avatarUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Lỗi Firebase Auth: ${e.message}");
      rethrow;
    } catch (e) {
      print("Lỗi đăng ký và lưu user: $e");
      rethrow;
    }
  }

  // Lấy role của user từ Firestore
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      print('Lỗi lấy user role: $e');
      return null;
    }
  }

  Future<void> signOut() => _auth.signOut();
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
