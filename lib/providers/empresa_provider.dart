import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/services/empresa_service.dart';

final empresaServiceProvider = Provider<EmpresaService>(
  (ref) => EmpresaService(),
);

class EmpresaNotifier {
  final Ref ref;

  EmpresaNotifier(this.ref);

  /// =====================================
  /// REFRESH
  /// =====================================
  Future<void> refresh() async {
    await ref.read(sessionProvider.notifier).refreshSession();
  }

  /// =====================================
  /// CAMBIAR EMPRESA
  /// =====================================
  Future<void> cambiarEmpresa(Empresa empresa) async {
    await ref.read(sessionProvider.notifier).cambiarEmpresa(empresa);
  }

  /// =====================================
  /// CREAR EMPRESA
  /// =====================================
  Future<Empresa?> crearEmpresa({
    required String nombreEmpresa,
    required String nombreSucursal,
    required String direccionSucursal,
    String? nitEmpresa,
  }) async {
    try {
      final session = ref.read(sessionProvider);
      final usuario = session.usuario;

      if (usuario == null) {
        throw Exception('Usuario no autenticado');
      }

      final empresa = Empresa(
        id: '',
        nombre: nombreEmpresa.trim(),
        nit: nitEmpresa?.trim().isEmpty == true ? null : nitEmpresa?.trim(),
      );

      final sucursal = Sucursal(
        id: '',
        empresaId: '',
        nombre: nombreSucursal.trim(),
        direccion: direccionSucursal.trim(),
      );

      final empresaCreada = await ref
          .read(empresaServiceProvider)
          .crearEmpresa(
            empresa: empresa,
            sucursalInicial: sucursal,
            usuarioId: usuario.id,
            rolAdministradorId: 'admin',
          );

      await ref.read(sessionProvider.notifier).refreshSession();

      await ref.read(sessionProvider.notifier).cambiarEmpresa(empresaCreada);

      return empresaCreada;
    } catch (e) {
      print('❌ crearEmpresa provider: $e');
      return null;
    }
  }
}

final empresaProvider = Provider<EmpresaNotifier>(
  (ref) => EmpresaNotifier(ref),
);
