import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_bloc.dart';
import 'package:time_tracker_app/app/sign_in/email_sign_in_model.dart';
import 'package:time_tracker_app/common_widgets/form_submit_button.dart';
import 'package:time_tracker_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';

class EmailSignInFormBlocBased extends StatefulWidget {
  const EmailSignInFormBlocBased({
    Key? key,
    required this.bloc,
  }) : super(key: key);

  final EmailSignInBloc bloc;

  static Widget create(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Provider<EmailSignInBloc>(
      create: (_) => EmailSignInBloc(auth: auth),
      child: Consumer<EmailSignInBloc>(
        builder: (_, bloc, __) => EmailSignInFormBlocBased(bloc: bloc),
      ),
      dispose: (_, bloc) => bloc.dispose(),
    );
  }

  @override
  State<EmailSignInFormBlocBased> createState() => _EmailSignInFormBlocBasedState();
}

class _EmailSignInFormBlocBasedState extends State<EmailSignInFormBlocBased> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

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
      await widget.bloc.submit();
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Sign in failed',
        exception: e,
      );
    }
  }

  void _toggleFormType(EmailSignInModel model) {
    widget.bloc.updateWith(
      email: '',
      password: '',
      formType:model.formType == EmailSignInFormType.signIn
            ? EmailSignInFormType.register
            : EmailSignInFormType.signIn,
      isLoading: false,
      submitted: false,
    );
    _emailController.clear();
    _passwordController.clear();
  }

  List<Widget> _buildChildren(EmailSignInModel model) {
    final primaryText = model.formType == EmailSignInFormType.signIn
        ? 'Sign in'
        : 'Create an account';
    final secondaryText = model.formType == EmailSignInFormType.signIn
        ? 'Need an account? Register'
        : 'Have an account? Sign in';

    bool submitEnabled = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        !model.isLoading;

    return [
      Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmailTextField(model),
            const SizedBox(height: 8.0),
            _buildPasswordTextField(model),
            const SizedBox(height: 8.0),
            FormSubmitButton(
              text: primaryText,
              onPressed: submitEnabled ? _submit : null,
            ),
            const SizedBox(height: 8.0),
            FlatButton(
              child: Text(secondaryText),
              onPressed: !model.isLoading ? () => _toggleFormType(model) : null,
            ),
          ],
        ),
      )
    ];
  }

  TextFormField _buildPasswordTextField(EmailSignInModel model) {
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
      onChanged: (password) => widget.bloc.updateWith(password: password),
      onEditingComplete: _submit,
    );
  }

  TextFormField _buildEmailTextField(EmailSignInModel model) {
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
      onChanged: (email) => widget.bloc.updateWith(email: email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<EmailSignInModel>(
      stream: widget.bloc.modelStream,
      initialData: EmailSignInModel(),
      builder: (context, snapshot) {
        final EmailSignInModel model = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _buildChildren(model),
          ),
        );
      }
    );
  }
}
