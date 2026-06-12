// archivo: services/proveedor_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// TODO: Reemplaza con la ruta correcta a tu modelo Env de configuración
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
// TODO: Reemplaza con la ruta correcta a tu modelo Proveedor

class ProveedorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Acceso a la colección 'proveedores' configurado por entorno
  CollectionReference<Map<String, dynamic>> get _proveedoresRef =>
      _db.collection(Env.col('proveedores'));

  // ==========================================================
  // OBTENER LISTADO POR EMPRESA (Petición única)
  // No es tiempo real, solo se ejecuta una vez.
  // ==========================================================
  Future<List<Proveedor>> getByEmpresa(String empresaId) async {
    try {
      final snapshot = await _proveedoresRef
          .where('empresaId', isEqualTo: empresaId)
          .where('eliminado', isEqualTo: false) // Solo no eliminados
          .orderBy('nombre') // Ordenados alfabéticamente
          .get();

      return snapshot.docs
          .map((e) => Proveedor.fromJson({...e.data(), 'id': e.id}))
          .toList();
    } catch (e) {
      print('❌ Error getByEmpresa (Proveedores): $e');
      rethrow; // Re-lanzar para que el provider lo maneje
    }
  }

  // ==========================================================
  // OBTENER POR ID (Detalle)
  // ==========================================================
  Future<Proveedor?> getById(String id) async {
    try {
      final doc = await _proveedoresRef.doc(id).get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return Proveedor.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('❌ Error getById (Proveedor): $e');
      rethrow;
    }
  }

  // ==========================================================
  // INSERTAR (Crear)
  // ==========================================================
  Future<void> create(Proveedor proveedor) async {
    try {
      // Forzamos mayúsculas antes de guardar por seguridad,
      // aunque el UI ya debería controlarlo.
      final proveedorFixed = proveedor.copyWith(
        nombre: proveedor.nombre.trim().toUpperCase(),
      );
      await _proveedoresRef.doc(proveedorFixed.id).set(proveedorFixed.toJson());
    } catch (e) {
      print('❌ Error create (Proveedor): $e');
      rethrow;
    }
  }

  // ==========================================================
  // ACTUALIZAR (Modificar)
  // ==========================================================
  Future<void> update(Proveedor proveedor) async {
    try {
      // Forzamos mayúsculas antes de guardar
      final proveedorFixed = proveedor.copyWith(
        nombre: proveedor.nombre.trim().toUpperCase(),
      );
      await _proveedoresRef
          .doc(proveedorFixed.id)
          .update(proveedorFixed.toJson());
    } catch (e) {
      print('❌ Error update (Proveedor): $e');
      rethrow;
    }
  }

  Future<bool> existeNombre({
    required String empresaId,
    required String nombre,
    String? excluirId, // Útil al editar para no validarse contra sí mismo
  }) async {
    try {
      final nombreNormalizado = nombre.trim().toUpperCase();

      final snapshot = await _proveedoresRef
          .where('empresaId', isEqualTo: empresaId)
          .where(
            'nombre',
            isEqualTo: nombreNormalizado,
          ) // Firestore es case-sensitive
          .where('eliminado', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) return false;

      if (excluirId == null) {
        // Es creación, si hay resultados, ya existe.
        return true;
      } else {
        // Es edición, verificar que el duplicado no sea el mismo documento.
        return snapshot.docs.any((doc) => doc.id != excluirId);
      }
    } catch (e) {
      print('❌ Error existeNombre (Proveedor): $e');
      return true; // Ante la duda, asumimos que existe para bloquear
    }
  }

  // ==========================================================
  // BORRADO LÓGICO (Actualización de Estado y Auditoría)
  // ==========================================================
  Future<void> delete({
    required String proveedorId,
    required String usuarioId,
  }) async {
    try {
      // No borramos el documento físicamente, solo actualizamos banderas y auditoría
      await _proveedoresRef.doc(proveedorId).update({
        'eliminado': true,
        'activo': false,
        'fechaEliminacion': DateTime.now().toIso8601String(),
        'usuarioEliminadorId': usuarioId,
      });
    } catch (e) {
      print('❌ Error delete (Proveedor): $e');
      rethrow;
    }
  }

  // ==========================================================
  // STREAM (Tiempo Real) - *Opcional pero recomendable tenerlo*
  // ==========================================================
  Stream<List<Proveedor>> streamEmpresa(String empresaId) {
    try {
      return _proveedoresRef
          .where('empresaId', isEqualTo: empresaId)
          .where('eliminado', isEqualTo: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((e) => Proveedor.fromJson({...e.data(), 'id': e.id}))
                .toList(),
          );
    } catch (e) {
      print('❌ Error streamEmpresa (Proveedores): $e');
      rethrow;
    }
  }
}
