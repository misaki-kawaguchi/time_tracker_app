import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_page.dart';
import 'package:time_tracker_app/app/sign_in/sign_in_bloc.dart';
import 'package:time_tracker_app/app/sign_in/sign_in_button.dart';
import 'package:time_tracker_app/app/sign_in/social_sign_in_button.dart';
import 'package:time_tracker_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  final SignInBloc bloc;

  static Widget create(BuildContext context) {
    return Provider<SignInBloc>(
      create: (_) => SignInBloc(),
      child: Consumer<SignInBloc>(
        builder: (_, bloc, __) => SignInPage(bloc: bloc),
      ),
    );
  }

  void _showSignInError(BuildContext context, Exception exception) {
    if (exception is FirebaseAuthException &&
        exception.code == 'ERROR_ABORTED_BY_USER') {
      return;
    }
    showExceptionAlertDialog(
      context,
      title: 'Sign in failed',
      exception: exception,
    );
  }

  // 匿名認証
  Future<void> _signInAnonymously(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      bloc.setIsLoading(true);
      await auth.signInAnonymously();
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      bloc.setIsLoading(false);
    }
  }

  // Googleサインイン
  Future<void> _signInWithGoogle(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      bloc.setIsLoading(true);
      await auth.signInWithGoogle();
    } on Exception catch (e) {
      _showSignInError(context, e);
    } finally {
      bloc.setIsLoading(false);
    }
  }

  void _signInWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => EmailSignInPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        elevation: 2,
      ),
      body: StreamBuilder<bool>(
          stream: bloc.isLoadingStream,
          initialData: false,
          builder: (context, snapshot) {
            return _buildContent(context, snapshot.data!);
          }),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildContent(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 50,
            child: _buildHeader(isLoading),
          ),
          const SizedBox(height: 48),
          SocialSignInButton(
            assetName: 'images/google-logo.png',
            text: 'Sign in with Google',
            textColor: Colors.black87,
            color: Colors.white,
            onPressed: () {
              if (!isLoading) {
                _signInWithGoogle(context);
              }
            },
          ),
          const SizedBox(height: 8),
          SignInButton(
            text: 'Sign in with email',
            textColor: Colors.white,
            color: Colors.teal[700]!,
            onPressed: () {
              if (!isLoading) {
                _signInWithEmail(context);
              }
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'or',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          SignInButton(
            text: 'Go anonymous',
            textColor: Colors.black,
            color: Colors.lime[300]!,
            onPressed: () {
              if (!isLoading) {
                _signInAnonymously(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isLoading) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return const Text(
      'Sign in',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
