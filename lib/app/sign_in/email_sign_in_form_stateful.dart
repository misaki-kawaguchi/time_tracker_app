import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_app/common_widgets/form_submit_button.dart';
import 'package:time_tracker_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';

class EmailSignInFormStateful extends StatefulWidget {
  const EmailSignInFormStateful({
    Key? key,
  }) : super(key: key);

  @override
  State<EmailSignInFormStateful> createState() => _EmailSignInFormStatefulState();
}

class _EmailSignInFormStatefulState extends State<EmailSignInFormStateful> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String get _email => _emailController.text;

  String get _password => _passwordController.text;
  EmailSignInFormType _formType = EmailSignInFormType.signIn;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      if (_formType == EmailSignInFormType.signIn) {
        await auth.signInWithEmailAndPassword(_email, _password);
      } else {
        await auth.createUserWithEmailAndPassword(_email, _password);
      }
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Sign in failed',
        exception: e,
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
