import 'package:flutter/material.dart';
import 'package:time_tracker_app/services/auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    required this.auth,
  }) : super(key: key);

  final AuthBase auth;

  Future<void> _signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          FlatButton(
            onPressed: _signOut,
            child: const Text(
              'Logout',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
