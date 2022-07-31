import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_tracker_app/app/home/models/job.dart';
import 'package:time_tracker_app/services/api_path.dart';

abstract class Database {
  Future<void> createJob(Job job);
  void readJobs();
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
  void readJobs() {
    final path = APIPath.jobs(uid);
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    snapshots.listen((snapshot) {
      snapshot.docs.forEach((snapshot) => print(snapshot.data()));
    });
  }

  Future<void> _setData({String? path, Map<String, dynamic>? data}) async {
    final reference = FirebaseFirestore.instance.doc(path!);
    print('$path: $data');
    await reference.set(data!);
  }
}

