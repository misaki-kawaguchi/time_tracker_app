import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthBase {
  User? get currentUser;
  Stream<User?> authStateChanges();
  Future<User> signInAnonymously();
  Future<void> signOut();
}

class Auth implements AuthBase{
  final _firebaseAuth = FirebaseAuth.instance;

  // ユーザーのサインイン状態の変更について通知する（サインインやサインアウト）
  @override
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => FirebaseAuth.instance.currentUser;

  // 匿名認証
  @override
  Future<User> signInAnonymously() async {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    return userCredential.user!;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
