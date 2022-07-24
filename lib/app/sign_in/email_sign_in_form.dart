import 'dart:io';

import 'package:flutter/material.dart';
import 'package:time_tracker_app/common_widgets/form_submit_button.dart';
import 'package:time_tracker_app/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';

enum EmailSignInFormType { signIn, register }

class EmailSignInForm extends StatefulWidget {
  const EmailSignInForm({
    Key? key,
    required this.auth,
  }) : super(key: key);

  final AuthBase auth;

  @override
  State<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;

  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      if (_formType == EmailSignInFormType.signIn) {
        await widget.auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await widget.auth.createUserWithEmailAndPassword(_email, _password);
      }
      Navigator.of(context).pop();
    } catch (e) {
      showAlertDialog(
        context,
        title: 'Sign in failed',
        content: e.toString(),
        defaultActionText: 'OK',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleFormType() {
    setState(() {
      _formType = _formType == EmailSignInFormType.signIn
          ? EmailSignInFormType.register
          : EmailSignInFormType.signIn;
    });
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
    final primaryText = _formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
    final secondaryText = _formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';

    bool submitEnabled = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !_isLoading;

    return [
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailTextField(),
            const SizedBox(height: 8.0),
            _buildPasswordTextField(),
            const SizedBox(height: 8.0),
            FormSubmitButton(
              text: primaryText,
              onPressed: submitEnabled ? _submit : null,
            ),
            const SizedBox(height: 8.0),
            FlatButton(
              child: Text(secondaryText),
              onPressed: !_isLoading ? _toggleFormType : null,
            ),
          ],
        ),
      )
    ];
  }

  TextFormField _buildPasswordTextField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'パスワードを入力してください';
        }
        const pattern = r'^[a-zA-Z0-9!-/:-@¥[-`{-~]{8,}$';
        final regExp = RegExp(pattern);
        if (!regExp.hasMatch(value)) {
          return '8文字以上の英数字記号で入力してください';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Password',
        enabled: _isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: (password) => _updateState(),
      onEditingComplete: _submit,
    );
  }

  TextFormField _buildEmailTextField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      autofocus: true,
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'メールアドレスを入力してください';
        }
        String pattern = r'^[0-9a-z_./?-]+@([0-9a-z-]+\.)+[0-9a-z-]+$';
        RegExp regExp = RegExp(pattern);
        if (!regExp.hasMatch(value)) {
          return '正しいメールアドレスを入力してください';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'test@test.com',
        enabled: _isLoading == false,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: (email) => _updateState(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _buildChildren(),
      ),
    );
  }

  void _updateState() {
    setState(() {});
  }
}
