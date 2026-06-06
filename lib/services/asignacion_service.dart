/*✔ buscar usuario por correo
✔ agregar usuario a empresa
✔ asignar sucursales
✔ asignar roles
✔ desactivar usuario de empresa
✔ obtener usuarios de empresa*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/usuario_empresa_permiso.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/models/usuario_sucursal_rol.dart';
import 'package:inv_telas/moduloAsignacion/utils/asignacion_mapper.dart';

class AsignacionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _db.collection(Env.col('usuarios'));

  CollectionReference<Map<String, dynamic>> get _empresasRef =>
      _db.collection(Env.col('empresas'));

  // ==========================================
  // BUSCAR USUARIO
  // ==========================================
  Future<Usuario?> buscarUsuarioPorCorreo(String correo) async {
    final result = await _usuariosRef
        .where('email', isEqualTo: correo.trim().toLowerCase())
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      return null;
    }

    return Usuario.fromJson(result.docs.first.data());
  }

  // ==========================================
  // AGREGAR USUARIO A EMPRESA
  // ==========================================
  Future<void> agregarUsuarioAEmpresa({
    required Empresa empresa,
    required Usuario usuario,
    required String usuarioAccionId,
  }) async {
    final empresaRol = AsignacionMapper.crearEmpresaRol(
      empresaId: empresa.id,
      sucursales: [],
      usuarioId: usuarioAccionId,
    );

    final permiso = AsignacionMapper.crearPermiso(
      usuarioId: usuario.id,
      sucursales: [],
    );

    final batch = _db.batch();

    // EMPRESA
    batch.update(_empresasRef.doc(empresa.id), {
      'usuariosPermitidos': FieldValue.arrayUnion([permiso.toJson()]),
    });

    // USUARIO
    batch.update(_usuariosRef.doc(usuario.id), {
      'empresas': FieldValue.arrayUnion([empresaRol.toJson()]),
    });

    await batch.commit();
  }

  // ==========================================
  // ASIGNAR SUCURSAL
  // ==========================================
  Future<void> asignarSucursal({
    required Empresa empresa,
    required Usuario usuario,
    required String sucursalId,
    required String usuarioAccionId,
  }) async {
    final empresaDoc = await _empresasRef.doc(empresa.id).get();

    final usuarioDoc = await _usuariosRef.doc(usuario.id).get();

    if (!empresaDoc.exists || !usuarioDoc.exists) {
      throw Exception('Datos no encontrados');
    }

    final empresaActual = Empresa.fromFirestore(empresaDoc);

    final usuariosPermitidos = empresaActual.usuariosPermitidos.map((e) {
      if (e.usuarioId != usuario.id) {
        return e;
      }

      final existe = e.sucursales.any((s) => s.sucursalId == sucursalId);

      if (existe) {
        return e;
      }

      return e.copyWith(
        sucursales: [
          ...e.sucursales,
          AsignacionMapper.crearSucursalRol(
            sucursalId: sucursalId,
            rolesIds: [],
            usuarioId: usuarioAccionId,
          ),
        ],
        fechaActualizacion: DateTime.now(),
      );
    }).toList();

    final usuarioData = usuarioDoc.data()!;

    final empresasUsuario = (usuarioData['empresas'] as List<dynamic>? ?? [])
        .map((e) => UsuarioEmpresaRol.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final empresasActualizadas = empresasUsuario.map((e) {
      if (e.empresaId != empresa.id) {
        return e;
      }

      final existe = e.sucursales.any((s) => s.sucursalId == sucursalId);

      if (existe) {
        return e;
      }

      return e.copyWith(
        sucursales: [
          ...e.sucursales,
          AsignacionMapper.crearSucursalRol(
            sucursalId: sucursalId,
            rolesIds: [],
            usuarioId: usuarioAccionId,
          ),
        ],
        fechaActualizacion: DateTime.now(),
      );
    }).toList();

    final batch = _db.batch();

    batch.update(_empresasRef.doc(empresa.id), {
      'usuariosPermitidos': usuariosPermitidos.map((e) => e.toJson()).toList(),
    });

    batch.update(_usuariosRef.doc(usuario.id), {
      'empresas': empresasActualizadas.map((e) => e.toJson()).toList(),
    });

    await batch.commit();
  }

  // ==========================================
  // ASIGNAR ROLES
  // ==========================================
  Future<void> asignarRoles({
    required Empresa empresa,
    required Usuario usuario,
    required String sucursalId,
    required List<String> rolesIds,
  }) async {
    final empresaDoc = await _empresasRef.doc(empresa.id).get();

    final usuarioDoc = await _usuariosRef.doc(usuario.id).get();

    if (!empresaDoc.exists || !usuarioDoc.exists) {
      throw Exception('Datos no encontrados');
    }

    final empresaActual = Empresa.fromFirestore(empresaDoc);

    final usuariosPermitidos = empresaActual.usuariosPermitidos.map((u) {
      if (u.usuarioId != usuario.id) {
        return u;
      }

      return u.copyWith(
        sucursales: u.sucursales.map((s) {
          if (s.sucursalId != sucursalId) {
            return s;
          }

          return s.copyWith(
            rolesIds: rolesIds,
            fechaActualizacion: DateTime.now(),
          );
        }).toList(),
      );
    }).toList();

    final usuarioData = usuarioDoc.data()!;

    final empresasUsuario = (usuarioData['empresas'] as List<dynamic>? ?? [])
        .map((e) => UsuarioEmpresaRol.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final empresasActualizadas = empresasUsuario.map((empresaRol) {
      if (empresaRol.empresaId != empresa.id) {
        return empresaRol;
      }

      return empresaRol.copyWith(
        sucursales: empresaRol.sucursales.map((s) {
          if (s.sucursalId != sucursalId) {
            return s;
          }

          return s.copyWith(
            rolesIds: rolesIds,
            fechaActualizacion: DateTime.now(),
          );
        }).toList(),
      );
    }).toList();

    final batch = _db.batch();

    batch.update(_empresasRef.doc(empresa.id), {
      'usuariosPermitidos': usuariosPermitidos.map((e) => e.toJson()).toList(),
    });

    batch.update(_usuariosRef.doc(usuario.id), {
      'empresas': empresasActualizadas.map((e) => e.toJson()).toList(),
    });

    await batch.commit();
  }
}
