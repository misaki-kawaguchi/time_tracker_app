import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_app/services/auth.dart';
import 'package:time_tracker_app/services/database.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({
    Key? key,
  }) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    final auth = Provider.of<AuthBase>(context, listen: false);
    try {
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final didRequestSignOut = await showAlertDialog(
      context,
      title: 'Logout',
      content: 'Are you sure that you want to logout?',
      cancelActionText: 'Cancel',
      defaultActionText: 'Logout',
    );
    if (didRequestSignOut == true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          FlatButton(
            onPressed: () => _confirmSignOut(context),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createJob(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createJob(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await database.createJob({
      'name': 'Blogging',
      'ratePerHour': 10,
    });
  }
}
