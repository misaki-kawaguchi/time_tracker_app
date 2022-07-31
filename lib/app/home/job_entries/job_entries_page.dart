import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_app/app/home/job_entries/entry_list_item.dart';
import 'package:time_tracker_app/app/home/job_entries/entry_page.dart';
import 'package:time_tracker_app/app/home/jobs/edit_job_page.dart';
import 'package:time_tracker_app/app/home/jobs/list_items_builder.dart';
import 'package:time_tracker_app/app/home/models/entry.dart';
import 'package:time_tracker_app/app/home/models/job.dart';
import 'package:time_tracker_app/common_widgets/show_exception_alert_dialog.dart';
import 'package:time_tracker_app/services/database.dart';

class JobEntriesPage extends StatelessWidget {
  const JobEntriesPage({
    Key? key,
    required this.database,
    required this.job,
  }) : super(key: key);

  final Database database;
  final Job job;

  static Future<void> show(BuildContext context, Job job) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (context) => JobEntriesPage(database: database, job: job),
      ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, Entry entry) async {
    try {
      await database.deleteEntry(entry);
    } on FirebaseException catch (e) {
      showExceptionAlertDialog(
        context,
        title: 'Operation failed',
        exception: e,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(job.name),
        actions: <Widget>[
          FlatButton(
            child: const Text(
              'Edit',
              style: TextStyle(fontSize: 18.0, color: Colors.white),
            ),
            onPressed: () => EditJobPage.show(context, job: job),
          ),
        ],
      ),
      body: _buildContent(context, job),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => EntryPage.show(context, database: database, job: job),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Job job) {
    return StreamBuilder<List<Entry>>(
      stream: database.entriesStream(job: job),
      builder: (context, snapshot) {
        return ListItemBuilder<Entry>(
          snapshot: snapshot,
          itemBuilder: (context, entry) {
            return DismissibleEntryListItem(
              key: Key('entry-${entry.id}'),
              entry: entry,
              job: job,
              onDismissed: () => _deleteEntry(context, entry),
              onTap: () => EntryPage.show(
                context,
                database: database,
                job: job,
                entry: entry,
              ),
            );
          },
        );
      },
    );
  }
}
