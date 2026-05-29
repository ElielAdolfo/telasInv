import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/sucursal.dart';

class SucursalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sucursalesRef =>
      _db.collection(Env.col('sucursales'));

  /// STREAM SUCURSALES
  Stream<List<Sucursal>> streamSucursales(String empresaId) {
    return _sucursalesRef
        .where('empresaId', isEqualTo: empresaId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Sucursal.fromJson({...doc.data(), 'id': doc.id}))
              .where((s) => !s.eliminado && s.activo)
              .toList();
        });
  }

  /// GUARDAR
  Future<void> guardarSucursal({
    required Sucursal sucursal,
    required String usuarioId,
  }) async {
    try {
      final now = DateTime.now();

      /// NUEVA
      if (sucursal.id.isEmpty) {
        final newDoc = _sucursalesRef.doc();

        final nuevaSucursal = sucursal.copyWith(
          id: newDoc.id,

          fechaCreacion: now,
          usuarioCreadorId: usuarioId,

          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,

          activo: true,
          eliminado: false,
        );

        await newDoc.set(nuevaSucursal.toJson());

        print('✅ Sucursal creada: ${nuevaSucursal.nombre}');
      }
      /// EDITAR
      else {
        final actualizada = sucursal.copyWith(
          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await _sucursalesRef
            .doc(sucursal.id)
            .set(actualizada.toJson(), SetOptions(merge: true));

        print('✏️ Sucursal actualizada');
      }
    } catch (e) {
      print('❌ guardarSucursal: $e');
      rethrow;
    }
  }

  /// ELIMINAR
  Future<void> eliminarSucursal({
    required String id,
    required String usuarioId,
  }) async {
    try {
      final now = Timestamp.now();

      await _sucursalesRef.doc(id).update({
        'activo': false,
        'eliminado': true,

        'fechaEliminacion': now,

        'usuarioEliminadorId': usuarioId,

        'fechaActualizacion': now,

        'usuarioModificadorId': usuarioId,
      });

      print('🗑️ Sucursal eliminada');
    } catch (e) {
      print('❌ eliminarSucursal: $e');
      rethrow;
    }
  }
}
