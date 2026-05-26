import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';

class RolAbmService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Rol>> streamRoles() {
    return _db
        .collection(Env.col('roles'))
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => Rol.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Future<void> guardarRol(Rol rol) async {
    final ref = _db.collection(Env.col('roles')).doc(rol.id);
    if (rol.id.isEmpty) {
      final newDoc = _db.collection(Env.col('roles')).doc();
      await newDoc.set(rol.toJson()..['id'] = newDoc.id);
    } else {
      await ref.set(rol.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> eliminarRol(String id) async {
    await _db.collection(Env.col('roles')).doc(id).delete();
  }
}
