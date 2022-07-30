import 'package:flutter/material.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_form_stateful.dart';

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
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Card(
            child: EmailSignInFormStateful(),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
