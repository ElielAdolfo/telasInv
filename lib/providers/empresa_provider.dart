import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/services/empresa_service.dart';

final empresaServiceProvider = Provider<EmpresaService>(
  (ref) => EmpresaService(),
);

/// =====================================
/// EMPRESAS DEL USUARIO
/// =====================================
final empresasUsuarioProvider = FutureProvider<List<Empresa>>((ref) async {
  final auth = ref.watch(authProvider);

  final usuario = auth.value;

  if (usuario == null) {
    return [];
  }

  final ids = usuario.empresas.map((e) => e.empresaId).toList();

  return ref.read(empresaServiceProvider).getEmpresasByIds(ids);
});

/// =====================================
/// EMPRESA NOTIFIER
/// =====================================
class EmpresaNotifier {
  final Ref ref;

  EmpresaNotifier(this.ref);

  /// REFRESH
  Future<void> refresh() async {
    ref.invalidate(empresasUsuarioProvider);

    await ref.read(sessionProvider.notifier).refreshSession();
  }

  /// CAMBIAR EMPRESA
  Future<void> cambiarEmpresa(Empresa empresa) async {
    await ref.read(sessionProvider.notifier).cambiarEmpresa(empresa);
  }
}

final empresaProvider = Provider<EmpresaNotifier>(
  (ref) => EmpresaNotifier(ref),
);
