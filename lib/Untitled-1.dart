import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/models/usuario_sucursal_rol.dart';
import 'package:inv_telas/models/empresa.dart';

class SucursalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sucursalesRef =>
      _db.collection(Env.col('sucursales'));

  CollectionReference<Map<String, dynamic>> get _empresaRef =>
      _db.collection(Env.col('empresas'));

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _db.collection(Env.col('usuarios'));

  /// GUARDAR / CREAR SUCURSAL (CORREGIDO)
  Future<void> guardarSucursal({
    required Sucursal sucursal,
    required String usuarioId,
  }) async {
    try {
      final now = DateTime.now();

      // =========================
      // NUEVA SUCURSAL
      // =========================
      if (sucursal.id.isEmpty) {
        final sucursalDoc = _sucursalesRef.doc();

        final nuevaSucursal = sucursal.copyWith(
          id: sucursalDoc.id,
          fechaCreacion: now,
          fechaActualizacion: now,
          usuarioCreadorId: usuarioId,
          usuarioModificadorId: usuarioId,
          activo: true,
          eliminado: false,
        );

        final empresaId = nuevaSucursal.empresaId;

        // =========================
        // CREAR ROL DE SUCURSAL
        // =========================
        final sucursalRol = UsuarioSucursalRol(
          sucursalId: sucursalDoc.id,
          rolesIds: ['admin'], // OPCIÓN A
          activo: true,
          eliminado: false,
          usuarioCreadorId: usuarioId,
          usuarioModificadorId: usuarioId,
          fechaCreacion: now,
          fechaActualizacion: now,
        );

        // =========================
        // LEER EMPRESA
        // =========================
        final empresaSnap = await _empresaRef.doc(empresaId).get();

        if (!empresaSnap.exists) {
          throw Exception('Empresa no encontrada');
        }

        final empresa = Empresa.fromFirestore(empresaSnap);

        final empresaActualizada = empresa.copyWith(
          usuariosPermitidos: empresa.usuariosPermitidos.map((u) {
            if (u.usuarioId != usuarioId) return u;

            return u.copyWith(
              sucursales: [...u.sucursales, sucursalRol],
              fechaActualizacion: now,
            );
          }).toList(),
          fechaActualizacion: now,
        );

        // =========================
        // LEER USUARIO
        // =========================
        final usuarioSnap = await _usuariosRef.doc(usuarioId).get();

        final usuarioData = usuarioSnap.data();

        if (usuarioData == null) {
          throw Exception('Usuario no encontrado');
        }

        final empresasUsuario =
            (usuarioData['empresas'] as List<dynamic>? ?? [])
                .map(
                  (e) =>
                      UsuarioEmpresaRol.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();

        final empresasActualizadas = empresasUsuario.map((e) {
          if (e.empresaId != empresaId) return e;

          return e.copyWith(
            sucursales: [...e.sucursales, sucursalRol],
            fechaActualizacion: now,
          );
        }).toList();

        // =========================
        // BATCH FINAL
        // =========================
        final batch = _db.batch();

        batch.set(sucursalDoc, nuevaSucursal.toJson());

        batch.update(_empresaRef.doc(empresaId), {
          'usuariosPermitidos': empresaActualizada.usuariosPermitidos
              .map((e) => e.toJson())
              .toList(),
        });

        batch.update(_usuariosRef.doc(usuarioId), {
          'empresas': empresasActualizadas.map((e) => e.toJson()).toList(),
        });

        await batch.commit();

        print('✅ Sucursal creada y sincronizada correctamente');
      }
      // =========================
      // EDITAR SUCURSAL
      // =========================
      else {
        final actualizada = sucursal.copyWith(
          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await _sucursalesRef
            .doc(sucursal.id)
            .set(actualizada.toJson(), SetOptions(merge: true));
      }
    } catch (e) {
      print('❌ guardarSucursal: $e');
      rethrow;
    }
  }

  /// ELIMINAR (igual que antes)
  Future<void> eliminarSucursal({
    required String id,
    required String usuarioId,
  }) async {
    await _sucursalesRef.doc(id).update({
      'activo': false,
      'eliminado': true,
      'fechaEliminacion': Timestamp.now(),
      'usuarioEliminadorId': usuarioId,
      'fechaActualizacion': Timestamp.now(),
      'usuarioModificadorId': usuarioId,
    });
  }

  Future<List<Sucursal>> getSucursales(String empresaId) async {
    final snapshot = await _sucursalesRef
        .where('empresaId', isEqualTo: empresaId)
        .get();

    return snapshot.docs
        .map((doc) => Sucursal.fromJson({...doc.data(), 'id': doc.id}))
        .where((s) => !s.eliminado && s.activo)
        .toList();
  }
}
