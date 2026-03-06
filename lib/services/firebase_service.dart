import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseFirestore get firestore => _firestore;
  String generarId() => _firestore.collection('temp').doc().id;

  Future<List<T>> getAll<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _firestore.collection(collectionPath);
    if (orderBy != null) query = query.orderBy(orderBy, descending: descending);
    final snapshot = await query.get();
    return snapshot.docs
        .map(
          (doc) =>
              fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}),
        )
        .toList();
  }

  Future<void> create({
    required String collectionPath,
    required String id,
    required Map<String, dynamic> data,
  }) async => await _firestore.collection(collectionPath).doc(id).set(data);
  
  Future<void> update({
    required String collectionPath,
    required String id,
    required Map<String, dynamic> data,
  }) async => await _firestore.collection(collectionPath).doc(id).update(data);
  Future<void> delete({
    required String collectionPath,
    required String id,
  }) async => await _firestore.collection(collectionPath).doc(id).delete();
}
