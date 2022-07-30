import 'package:flutter/material.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_form_bloc_change_notifier.dart';

class EmailSignInPage extends StatelessWidget {
  const EmailSignInPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: EmailSignInFormBlocChangeNotifier.create(context),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
