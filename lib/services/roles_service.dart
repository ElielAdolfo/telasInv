import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';

class RolesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Referencia a la colección de roles
  CollectionReference<Map<String, dynamic>> get _rolesRef =>
      _db.collection(Env.col('roles'));

  /// Obtener una lista de roles específicos por sus IDs
  /// Ideal para cargar solo los roles que tiene un usuario asignado.
  Future<List<Rol>> getRolesByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      // Firestore permite consultar hasta 10 documentos con 'whereIn'
      // Si un usuario tuviera más de 10 roles (muy raro), habría que hacer batches.
      // Para este sistema, 10 es más que suficiente.
      final snapshot = await _rolesRef
          .where(FieldPath.documentId, whereIn: ids)
          .get();

      return snapshot.docs.map((doc) => Rol.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error en getRolesByIds: $e');
      return [];
    }
  }

  /// Obtener un solo rol por su ID
  Future<Rol?> getRolById(String id) async {
    try {
      final doc = await _rolesRef.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Rol.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error en getRolById: $e');
      return null;
    }
  }

  /// Crear o Actualizar un rol
  Future<void> saveRol(Rol rol) async {
    try {
      await _rolesRef.doc(rol.id).set(rol.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error guardando rol: $e');
      rethrow;
    }
  }

  /// Eliminar un rol (Solo si no está asignado a usuarios, se recomienda validación previa)
  Future<void> deleteRol(String id) async {
    try {
      await _rolesRef.doc(id).delete();
    } catch (e) {
      print('Error eliminando rol: $e');
      rethrow;
    }
  }
}
