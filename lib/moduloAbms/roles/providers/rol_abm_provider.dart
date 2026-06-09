// Archivo: lib/moduloAbms/roles/providers/rol_abm_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/moduloAbms/roles/services/rol_abm_service.dart';

// 👇 IMPORTANTE: Importar el archivo donde está definido 'menuServiceProvider'
import 'package:inv_telas/core/providers/session_provider.dart'; 

final rolAbmServiceProvider = Provider((ref) => RolAbmService());

final rolesAbmStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(rolAbmServiceProvider).streamRoles();
});

// Provider para traer todos los menús disponibles
final allMenusForSelectProvider = FutureProvider.autoDispose((ref) async {
  // Ahora 'menuServiceProvider' sí es reconocido porque lo importamos arriba
  return ref.watch(menuServiceProvider).getAllMenus();
});