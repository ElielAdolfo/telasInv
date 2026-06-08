import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

import 'package:inv_telas/services/asignacion_service.dart';

final asignacionServiceProvider = Provider<AsignacionService>(
  (ref) => AsignacionService(),
);

class AsignacionNotifier {
  final Ref ref;

  AsignacionNotifier(this.ref);

  AsignacionService get _service =>
      ref.read(asignacionServiceProvider);

  Future<Usuario?> buscarUsuarioPorCorreo(String correo) {
    return _service.buscarUsuarioPorCorreo(correo);
  }

  Future<void> agregarUsuarioAEmpresa({
    required Empresa empresa,
    required Usuario usuario,
  }) async {
    final usuarioActual =
        ref.read(sessionProvider).usuario;

    if (usuarioActual == null) {
      throw Exception('Usuario no autenticado');
    }

    await _service.agregarUsuarioAEmpresa(
      empresa: empresa,
      usuario: usuario,
      usuarioAccionId: usuarioActual.id,
    );
  }

  Future<void> asignarSucursal({
    required Empresa empresa,
    required Usuario usuario,
    required String sucursalId,
  }) async {
    final usuarioActual =
        ref.read(sessionProvider).usuario;

    if (usuarioActual == null) {
      throw Exception('Usuario no autenticado');
    }

    await _service.asignarSucursal(
      empresa: empresa,
      usuario: usuario,
      sucursalId: sucursalId,
      usuarioAccionId: usuarioActual.id,
    );
  }

  Future<void> asignarRoles({
    required Empresa empresa,
    required Usuario usuario,
    required String sucursalId,
    required List<String> rolesIds,
  }) async {
    await _service.asignarRoles(
      empresa: empresa,
      usuario: usuario,
      sucursalId: sucursalId,
      rolesIds: rolesIds,
    );
  }

  /// NUEVO
  Future<void> sincronizarSucursalesUsuario({
    required String empresaId,
    required String usuarioId,
    required List<String> sucursalesSeleccionadas,
  }) async {
    final usuarioActual =
        ref.read(sessionProvider).usuario;

    if (usuarioActual == null) {
      throw Exception('Usuario no autenticado');
    }

    await _service.sincronizarSucursalesUsuario(
      empresaId: empresaId,
      usuarioId: usuarioId,
      sucursalesSeleccionadas: sucursalesSeleccionadas,
      usuarioAccionId: usuarioActual.id,
    );
  }
}

final asignacionProvider =
    Provider<AsignacionNotifier>(
  (ref) => AsignacionNotifier(ref),
);