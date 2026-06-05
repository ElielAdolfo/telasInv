import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario_empresa_permiso.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/models/usuario_sucursal_rol.dart';

class EmpresaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _empresaRef =>
      _db.collection(Env.col('empresas'));

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _db.collection(Env.col('usuarios'));

  // ==========================================
  // OBTENER EMPRESAS DEL USUARIO
  // ==========================================
  Future<List<Empresa>> getEmpresasByIds(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];

      final futures = ids.map((id) => _empresaRef.doc(id).get());

      final docs = await Future.wait(futures);

      return docs
          .where((d) => d.exists)
          .map((d) => Empresa.fromFirestore(d))
          .where((e) => !e.eliminado)
          .toList();
    } catch (e) {
      print('❌ getEmpresasByIds: $e');
      rethrow;
    }
  }

  // ==========================================
  // CREAR EMPRESA
  // ==========================================
  Future<Empresa> crearEmpresa({
    required Empresa empresa,
    required String usuarioId,
    required String rolAdministradorId,
  }) async {
    try {
      final doc = _empresaRef.doc();

      final nuevaEmpresa = empresa.copyWith(
        id: doc.id,
        fechaCreacion: DateTime.now(),
        usuarioCreadorId: usuarioId,
        fechaActualizacion: DateTime.now(),
        usuarioModificadorId: usuarioId,
        eliminado: false,
        activo: true,
        usuariosPermitidos: [
          UsuarioEmpresaPermiso(
            usuarioId: usuarioId,
            sucursales: [],
            esPrincipal: true,
            puedeVender: true,
            puedeConsultar: true,
            activo: true,
            eliminado: false,
            usuarioCreadorId: usuarioId,
            usuarioModificadorId: usuarioId,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now(),
          ),
        ],
      );

      final batch = _db.batch();

      batch.set(doc, nuevaEmpresa.toFirestore());

      batch.update(_usuariosRef.doc(usuarioId), {
        'empresas': FieldValue.arrayUnion([
          UsuarioEmpresaRol(
            empresaId: doc.id,
            sucursales: [],
            activo: true,
            eliminado: false,
            usuarioCreadorId: usuarioId,
            usuarioModificadorId: usuarioId,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now(),
          ).toJson(),
        ]),
      });

      await batch.commit();

      print('✅ Empresa creada correctamente');

      /// DEVOLVER EMPRESA
      return nuevaEmpresa;
    } catch (e) {
      print('❌ crearEmpresa: $e');
      rethrow;
    }
  }

  // ==========================================
  // ACTUALIZAR EMPRESA
  // ==========================================
  Future<void> actualizarEmpresa(Empresa empresa, String usuarioId) async {
    try {
      await _empresaRef
          .doc(empresa.id)
          .set(
            empresa
                .copyWith(
                  fechaActualizacion: DateTime.now(),
                  usuarioModificadorId: usuarioId,
                )
                .toFirestore(),
            SetOptions(merge: true),
          );
    } catch (e) {
      print('❌ actualizarEmpresa: $e');
      rethrow;
    }
  }

  // ==========================================
  // ELIMINACIÓN LÓGICA
  // ==========================================
  Future<void> eliminarEmpresa({
    required String empresaId,
    required String usuarioId,
  }) async {
    try {
      await _empresaRef.doc(empresaId).update({
        'activo': false,
        'eliminado': true,
        'fechaEliminacion': Timestamp.now(),
        'usuarioEliminadorId': usuarioId,
        'fechaActualizacion': Timestamp.now(),
        'usuarioModificadorId': usuarioId,
      });
    } catch (e) {
      print('❌ eliminarEmpresa: $e');
      rethrow;
    }
  }

  // ==========================================
  // AGREGAR USUARIO A EMPRESA
  // ==========================================
  Future<void> agregarUsuarioAEmpresa({
    required String empresaId,
    required String usuarioId,
    required List<UsuarioSucursalRol> sucursales,
    bool esPrincipal = false,
  }) async {
    try {
      final permiso = UsuarioEmpresaPermiso(
        usuarioId: usuarioId,
        sucursales: sucursales,
        esPrincipal: esPrincipal,
        puedeVender: !esPrincipal,
        puedeConsultar: true,
        activo: true,
        eliminado: false,
        usuarioCreadorId: usuarioId,
        usuarioModificadorId: usuarioId,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      await _empresaRef.doc(empresaId).update({
        'usuariosPermitidos': FieldValue.arrayUnion([permiso.toJson()]),
      });

      await _usuariosRef.doc(usuarioId).update({
        'empresas': FieldValue.arrayUnion([
          UsuarioEmpresaRol(
            empresaId: empresaId,
            sucursales: sucursales,
            activo: true,
            eliminado: false,
            usuarioCreadorId: usuarioId,
            usuarioModificadorId: usuarioId,
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now(),
          ).toJson(),
        ]),
      });
    } catch (e) {
      print('❌ agregarUsuarioAEmpresa: $e');
      rethrow;
    }
  }

  // ==========================================
  // CAMBIAR ROLES
  // ==========================================
  Future<void> cambiarRolesUsuario({
    required String empresaId,
    required String usuarioId,
    required String sucursalId,
    required List<String> nuevosRoles,
  }) async {
    try {
      final empresaDoc = await _empresaRef.doc(empresaId).get();
      final usuarioDoc = await _usuariosRef.doc(usuarioId).get();

      if (!empresaDoc.exists || !usuarioDoc.exists) {
        return;
      }

      final empresa = Empresa.fromFirestore(empresaDoc);

      // ==========================
      // ACTUALIZAR EMPRESA
      // ==========================
      final usuariosActualizados = empresa.usuariosPermitidos.map((u) {
        if (u.usuarioId != usuarioId) {
          return u;
        }

        final sucursalesActualizadas = u.sucursales.map((s) {
          if (s.sucursalId != sucursalId) {
            return s;
          }

          return s.copyWith(
            rolesIds: nuevosRoles,
            fechaActualizacion: DateTime.now(),
          );
        }).toList();

        return u.copyWith(
          sucursales: sucursalesActualizadas,
          fechaActualizacion: DateTime.now(),
        );
      }).toList();

      // ==========================
      // ACTUALIZAR USUARIO
      // ==========================
      final usuarioData = usuarioDoc.data()!;

      final empresasUsuario = (usuarioData['empresas'] as List<dynamic>? ?? [])
          .map((e) => UsuarioEmpresaRol.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      final empresasActualizadas = empresasUsuario.map((empresaRol) {
        if (empresaRol.empresaId != empresaId) {
          return empresaRol;
        }

        final sucursalesActualizadas = empresaRol.sucursales.map((s) {
          if (s.sucursalId != sucursalId) {
            return s;
          }

          return s.copyWith(
            rolesIds: nuevosRoles,
            fechaActualizacion: DateTime.now(),
          );
        }).toList();

        return empresaRol.copyWith(
          sucursales: sucursalesActualizadas,
          fechaActualizacion: DateTime.now(),
        );
      }).toList();

      final batch = _db.batch();

      batch.update(_empresaRef.doc(empresaId), {
        'usuariosPermitidos': usuariosActualizados
            .map((e) => e.toJson())
            .toList(),
      });

      batch.update(_usuariosRef.doc(usuarioId), {
        'empresas': empresasActualizadas.map((e) => e.toJson()).toList(),
      });

      await batch.commit();

      print('✅ Roles sincronizados');
    } catch (e) {
      print('❌ cambiarRolesUsuario: $e');
      rethrow;
    }
  }
}
