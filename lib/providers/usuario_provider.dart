import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

import 'package:inv_telas/services/usuario_service.dart';

final usuarioServiceProvider = Provider<UsuarioService>(
  (ref) => UsuarioService(),
);

/// =================================================
/// OBTENER USUARIOS DE UNA EMPRESA
/// =================================================
final usuariosEmpresaProvider = FutureProvider.family<List<Usuario>, String>((
  ref,
  empresaId,
) async {
  if (empresaId.isEmpty) {
    return [];
  }

  return ref.read(usuarioServiceProvider).getUsuariosByEmpresaId(empresaId);
});

/// =================================================
/// OBTENER USUARIOS PERMITIDOS
/// SEGÚN empresa.usuariosPermitidos
/// =================================================
final usuariosPermitidosProvider =
    FutureProvider.family<List<Usuario>, Empresa>((ref, empresa) async {
      return ref.read(usuarioServiceProvider).getUsuariosPermitidos(empresa);
    });

/// =================================================
/// OBTENER USUARIO POR ID
/// =================================================
final usuarioProvider = FutureProvider.family<Usuario?, String>((
  ref,
  usuarioId,
) async {
  if (usuarioId.isEmpty) {
    return null;
  }

  return ref.read(usuarioServiceProvider).getUsuarioById(usuarioId);
});
