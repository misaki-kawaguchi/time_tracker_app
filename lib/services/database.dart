import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_tracker_app/app/home/models/job.dart';
import 'package:time_tracker_app/services/api_path.dart';

abstract class Database {
  Future<void> createJob(Job job);

  Stream<List<Job>> jobsStream();
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({required this.uid}) : assert(uid != null);

  final String uid;

  @override
  Future<void> createJob(Job job) => _setData(
        path: APIPath.job(uid, 'job_abc'),
        data: job.toMap(),
      );

  @override
  Stream<List<Job>> jobsStream() => _collectionStream(
    path: APIPath.jobs(uid),
    builder: (data) => Job.fromMap(data),
  );

  Future<void> _setData({String? path, Map<String, dynamic>? data}) async {
    final reference = FirebaseFirestore.instance.doc(path!);
    print('$path: $data');
    await reference.set(data!);
  }

  Stream<List<T>> _collectionStream<T>(
      {required String path,
      required T Function(Map<String, dynamic> data) builder}) {
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map(
      (snapshot) => snapshot.docs
          .map(
            (snapshot) => builder(snapshot.data()),
          )
          .toList(),
    );
  }
}
