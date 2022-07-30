import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_change_model.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_app/common_widgets/form_submit_button.dart';
import 'package:time_tracker_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';

class EmailSignInFormBlocChangeNotifier extends StatefulWidget {
  const EmailSignInFormBlocChangeNotifier({
    Key? key,
    required this.model,
  }) : super(key: key);

  final EmailSignInChangeModel model;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return ChangeNotifierProvider<EmailSignInChangeModel>(
      create: (_) => EmailSignInChangeModel(auth: auth),
      child: Consumer<EmailSignInChangeModel>(
        builder: (_, model, __) => EmailSignInFormBlocChangeNotifier(model: model),
      ),
    );
  }

  @override
  State<EmailSignInFormBlocChangeNotifier> createState() => _EmailSignInFormBlocChangeNotifierState();
}

class _EmailSignInFormBlocChangeNotifierState extends State<EmailSignInFormBlocChangeNotifier> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  EmailSignInChangeModel get model => widget.model;

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
    try {
      await model.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Sign in failed',
        exception: e,
      );
    }
  }

  void _toggleFormType() {
    model.toggleFormType();
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren() {
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
              text: model.primaryButtonText,
              onPressed: model.canSubmit(_emailController.text, _passwordController.text) ? _submit : null,
            ),
            const SizedBox(height: 8.0),
            FlatButton(
              child: Text(model.secondaryButtonText),
              onPressed: !model.isLoading ? () => _toggleFormType : null,
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
        enabled: model.isLoading == false,
      ),
      obscureText: true,
      textInputAction: TextInputAction.done,
      onChanged: model.updatePassword,
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
        enabled: model.isLoading == false,
      ),
      autocorrect: false,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onChanged: model.updateEmail,
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
}
