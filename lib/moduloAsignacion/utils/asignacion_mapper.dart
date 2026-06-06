import 'package:inv_telas/models/usuario_empresa_permiso.dart';
import 'package:inv_telas/models/usuario_empresa_rol.dart';
import 'package:inv_telas/models/usuario_sucursal_rol.dart';

class AsignacionMapper {
  const AsignacionMapper._();

  static UsuarioSucursalRol crearSucursalRol({
    required String sucursalId,
    required List<String> rolesIds,
    required String usuarioId,
  }) {
    final now = DateTime.now();

    return UsuarioSucursalRol(
      sucursalId: sucursalId,
      rolesIds: rolesIds,
      activo: true,
      eliminado: false,
      usuarioCreadorId: usuarioId,
      usuarioModificadorId: usuarioId,
      fechaCreacion: now,
      fechaActualizacion: now,
    );
  }

  static UsuarioEmpresaRol crearEmpresaRol({
    required String empresaId,
    required List<UsuarioSucursalRol> sucursales,
    required String usuarioId,
  }) {
    final now = DateTime.now();

    return UsuarioEmpresaRol(
      empresaId: empresaId,
      sucursales: sucursales,
      activo: true,
      eliminado: false,
      usuarioCreadorId: usuarioId,
      usuarioModificadorId: usuarioId,
      fechaCreacion: now,
      fechaActualizacion: now,
    );
  }

  static UsuarioEmpresaPermiso crearPermiso({
    required String usuarioId,
    required List<UsuarioSucursalRol> sucursales,
  }) {
    final now = DateTime.now();

    return UsuarioEmpresaPermiso(
      usuarioId: usuarioId,
      sucursales: sucursales,
      esPrincipal: false,
      puedeVender: true,
      puedeConsultar: true,
      activo: true,
      eliminado: false,
      usuarioCreadorId: usuarioId,
      usuarioModificadorId: usuarioId,
      fechaCreacion: now,
      fechaActualizacion: now,
    );
  }
}
