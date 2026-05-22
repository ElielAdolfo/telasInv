import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';

class RolAdminService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('roles'));

  Future<void> saveRol(Rol rol) async {
    if (rol.id.isEmpty) {
      final newDoc = _ref.doc();
      final newRol = Rol(
        id: newDoc.id,
        nombre: rol.nombre,
        activo: rol.activo,
        menusPermitidos: rol.menusPermitidos,
        eliminado: false,
      );
      await newDoc.set(newRol.toJson());
    } else {
      await _ref.doc(rol.id).update(rol.toJson());
    }
  }

  Future<void> deleteRolLogic(String id) async {
    await _ref.doc(id).update({'eliminado': true});
  }

  Future<List<Rol>> getRoles() async {
    final snap = await _ref
        .where('eliminado', isEqualTo: false)
        .orderBy('nombre')
        .get();

    return snap.docs.map((d) => Rol.fromJson(d.data())).toList();
  }
}
