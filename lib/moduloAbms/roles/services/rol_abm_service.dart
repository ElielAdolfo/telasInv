import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';

class RolAbmService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rolesRef =>
      _db.collection(Env.col('roles'));

  /// STREAM ROLES
  /// realtime estable
  Stream<List<Rol>> streamRoles() {
    return _rolesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Rol.fromJson({...doc.data(), 'id': doc.id}))
          // FILTRADO EN MEMORIA
          .where((r) => !(r.eliminado ?? false) && (r.activo ?? true))
          .toList();
    });
  }

  /// CREAR / EDITAR ROL
  Future<void> guardarRol(Rol rol, String usuarioId) async {
    try {
      final now = DateTime.now();

      // NUEVO
      if (rol.id.isEmpty) {
        final newDoc = _rolesRef.doc();

        final nuevoRol = rol.copyWith(
          id: newDoc.id,

          eliminado: false,

          fechaCreacion: now,
          usuarioCreadorId: usuarioId,

          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await newDoc.set(nuevoRol.toJson());

        print('✅ Rol creado: ${nuevoRol.nombre}');
      }
      // EDITAR
      else {
        final rolActualizado = rol.copyWith(
          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await _rolesRef
            .doc(rol.id)
            .set(rolActualizado.toJson(), SetOptions(merge: true));

        print('✏️ Rol actualizado: ${rol.nombre}');
      }
    } catch (e) {
      print('❌ Error guardarRol: $e');
      rethrow;
    }
  }

  /// ELIMINACION LOGICA
  Future<void> eliminarRol(String id, String usuarioId) async {
    try {
      final now = Timestamp.now();

      await _rolesRef.doc(id).update({
        'eliminado': true,

        'activo': false,

        'fechaEliminacion': now,

        'usuarioEliminadorId': usuarioId,

        'fechaActualizacion': now,

        'usuarioModificadorId': usuarioId,
      });

      print('🗑️ Rol eliminado: $id');
    } catch (e) {
      print('❌ Error eliminarRol: $e');
      rethrow;
    }
  }

  /// RESTAURAR ROL
  Future<void> restaurarRol(String id, String usuarioId) async {
    try {
      final now = Timestamp.now();

      await _rolesRef.doc(id).update({
        'eliminado': false,

        'activo': true,

        'fechaEliminacion': null,

        'usuarioEliminadorId': null,

        'fechaActualizacion': now,

        'usuarioModificadorId': usuarioId,
      });

      print('♻️ Rol restaurado');
    } catch (e) {
      print('❌ Error restaurarRol: $e');
      rethrow;
    }
  }

  /// TODOS LOS ROLES
  /// incluye eliminados
  Stream<List<Rol>> streamTodosRoles() {
    return _rolesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Rol.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// SOLO ELIMINADOS
  Stream<List<Rol>> streamRolesEliminados() {
    return _rolesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Rol.fromJson({...doc.data(), 'id': doc.id}))
          .where((r) => r.eliminado ?? false)
          .toList();
    });
  }
}
