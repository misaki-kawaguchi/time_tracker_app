import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_tracker_app/services/auth.dart';

class SignInBloc {
  SignInBloc({required this.auth});
  final AuthBase auth;

  // 読み込み状態を管理
  final StreamController<bool> _isLoadingController = StreamController<bool>();
  Stream<bool> get isLoadingStream => _isLoadingController.stream;

  void dispose() {
    _isLoadingController.close();
  }

  void _setIsLoading(bool isLoading) => _isLoadingController.add(isLoading);

  Future<User> _signIn(Future<User> Function() signInMethod) async {
    try {
      _setIsLoading(true);
      return await signInMethod();
    } catch(e) {
      rethrow;
    }finally {
      _setIsLoading(false);
    }
  }

  Future<User> signInAnonymously() async => await _signIn(auth.signInAnonymously);

  Future<User> signInWithGoogle() async => await _signIn(auth.signInWithGoogle);
}