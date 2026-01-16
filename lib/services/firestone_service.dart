import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTasks() {
    return _db.collection('tasks').snapshots();
  }

  Stream<QuerySnapshot> getMaterials() {
    return _db.collection('materials').snapshots();
  }

  Future<void> addReport(String type, String description) {
    return _db.collection('reports').add({
      'type': type,
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }
}

