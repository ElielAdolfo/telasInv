import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/usuario_sucursal_rol.dart';
import 'package:inv_telas/providers/asignacion_provider.dart';

final posAutorizacionProvider = FutureProvider.family<bool, String>((
  ref,
  sucursalId,
) async {
  final session = ref.watch(sessionProvider);

  final usuario = session.usuario;
  final empresa = session.empresaActual;

  if (usuario == null || empresa == null) {
    print('❌ Usuario o empresa nulos');
    return false;
  }

  print('');
  print('======================================');
  print('🔐 VALIDANDO PERMISO DE VENTA');
  print('Usuario : ${usuario.id}');
  print('Sucursal: $sucursalId');
  print('Empresa : ${empresa.id}');
  print('======================================');

  final asignaciones = await ref
      .read(asignacionProvider)
      .obtenerSucursalesVentaUsuario(
        empresaId: empresa.id,
        usuarioId: usuario.id,
      );

  print('📋 Asignaciones encontradas: ${asignaciones.length}');

  for (final UsuarioSucursalRol s in asignaciones) {
    print('➡ sucursal=${s.sucursalId} | autorizadoVenta=${s.autorizadoVenta}');
  }

  final resultado = asignaciones.any(
    (UsuarioSucursalRol s) => s.sucursalId == sucursalId && s.autorizadoVenta,
  );

  print('✅ RESULTADO FINAL = $resultado');
  print('======================================');
  print('');

  return resultado;
});
