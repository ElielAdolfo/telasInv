import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/moduloConfiguracion/providers/configuracion_provider.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/services/relaciones_service.dart';
import 'package:inv_telas/services/roles_service.dart'; // O donde tengas el servicio de roles

// Estado: El ID del rol activo
final activeRoleIdProvider = StateProvider<String?>((ref) {
  // Por defecto, tomamos el primer rol del usuario logueado
  final user = ref.watch(authProvider).value;
  return (user != null && user.rolesIds.isNotEmpty)
      ? user.rolesIds.first
      : null;
});

// Lógica: Lista de objetos Rol completos que el usuario tiene asignados
final userRolesProvider = FutureProvider<List<Rol>>((ref) async {
  ref.keepAlive();

  final user = ref.watch(authProvider).value;

  if (user == null || user.rolesIds.isEmpty) {
    return [];
  }

  final rolesService = RolesService();

  return await rolesService.getRolesByIds(user.rolesIds);
});
// Lógica: El objeto Rol activo completo
final activeRoleProvider = Provider<Rol?>((ref) {
  final activeId = ref.watch(activeRoleIdProvider);

  final rolesAsync = ref.watch(userRolesProvider);

  final roles = rolesAsync.maybeWhen(
    data: (data) => data,
    orElse: () => <Rol>[],
  );

  if (activeId == null) return null;

  try {
    return roles.firstWhere((r) => r.id == activeId);
  } catch (e) {
    return null;
  }
});

/// Provider que calcula los IDs de menús permitidos para el usuario actual
/*final allowedMenuIdsProvider = Provider<Set<String>>((ref) {

  // 1. Obtenemos el usuario logueado
  final usuarioAsync = ref.watch(authProvider);
  final usuario = usuarioAsync.value;

  if (usuario == null) return {};

  // 2. Obtenemos la lista de TODOS los roles (usando el provider del módulo configuración)
  final rolesAsync = ref.watch(rolesAdminProvider);

  return rolesAsync.when(
    data: (roles) {
      // 3. Filtramos los roles que posee el usuario
      final userRoleIds = usuario.rolesIds;

      // 4. Agregamos soporte para menús personalizados del usuario
      // (Si tu modelo Usuario tiene el campo menuPersonalizado que vimos en el JSON)
      final customMenus = usuario.menuPersonalizado
          .map((m) => m.menuId)
          .toSet();

      // 5. Buscamos los objetos Rol completos y extraemos sus menús
      final allowedIds = <String>{};

      for (var rol in roles) {
        if (userRoleIds.contains(rol.id) && rol.activo) {
          allowedIds.addAll(rol.menusPermitidos);
        }
      }

      // Combinamos con menús personalizados directos (si aplica)
      allowedIds.addAll(customMenus);

      return allowedIds;
    },
    loading: () => {},
    error: (e, st) {
      print("Error cargando roles para menús: $e");
      return {};
    },
  );
});
*/

final allowedMenuIdsProvider = Provider<Set<String>>((ref) {
  final usuario = ref.watch(authProvider).value;

  if (usuario == null) {
    return {};
  }

  // ✅ USAR LOS ROLES DEL USUARIO
  final rolesAsync = ref.watch(userRolesProvider);

  return rolesAsync.maybeWhen(
    data: (roles) {
      final allowedIds = <String>{};

      print("======== ROLES USER ========");

      for (final rol in roles) {
        print("ROL:");
        print(rol.nombre);

        print("MENUS:");
        print(rol.menusPermitidos);

        if (rol.activo) {
          allowedIds.addAll(rol.menusPermitidos);
        }
      }

      // ✅ MENÚS PERSONALIZADOS
      final customMenus = usuario.menuPersonalizado
          .map((m) => m.menuId)
          .toSet();

      allowedIds.addAll(customMenus);

      print("======== IDS FINALES ========");
      print(allowedIds);

      return allowedIds;
    },
    orElse: () => {},
  );
});
