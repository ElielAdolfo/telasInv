import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario_empresa_permiso.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';

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
            rolesIds: [rolAdministradorId],
            esPrincipal: true,
            puedeVender: true,
            puedeConsultar: true,
          ),
        ],
      );

      final batch = _db.batch();

      batch.set(doc, nuevaEmpresa.toFirestore());

      batch.update(_usuariosRef.doc(usuarioId), {
        'empresas': FieldValue.arrayUnion([
          UsuarioEmpresaRol(
            empresaId: doc.id,
            rolesIds: [rolAdministradorId],
            sucursalesIds: [],
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
    required List<String> rolesIds,
    bool esPrincipal = false,
  }) async {
    try {
      final permiso = UsuarioEmpresaPermiso(
        usuarioId: usuarioId,
        rolesIds: rolesIds,
        esPrincipal: esPrincipal,
        puedeVender: !esPrincipal,
        puedeConsultar: true,
      );

      await _empresaRef.doc(empresaId).update({
        'usuariosPermitidos': FieldValue.arrayUnion([permiso.toJson()]),
      });

      await _usuariosRef.doc(usuarioId).update({
        'empresas': FieldValue.arrayUnion([
          UsuarioEmpresaRol(
            empresaId: empresaId,
            rolesIds: rolesIds,
            sucursalesIds: [],
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
    required List<String> nuevosRoles,
  }) async {
    try {
      final empresaDoc = await _empresaRef.doc(empresaId).get();

      if (!empresaDoc.exists) return;

      final empresa = Empresa.fromFirestore(empresaDoc);

      final usuariosActualizados = empresa.usuariosPermitidos.map((u) {
        if (u.usuarioId == usuarioId) {
          return UsuarioEmpresaPermiso(
            usuarioId: u.usuarioId,
            rolesIds: nuevosRoles,
            esPrincipal: u.esPrincipal,
            puedeVender: u.puedeVender,
            puedeConsultar: u.puedeConsultar,
          );
        }

        return u;
      }).toList();

      await _empresaRef.doc(empresaId).update({
        'usuariosPermitidos': usuariosActualizados
            .map((e) => e.toJson())
            .toList(),
      });
    } catch (e) {
      print('❌ cambiarRolesUsuario: $e');
      rethrow;
    }
  }
}
