import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';

import '../services/menu_admin_service.dart';
import '../services/rol_admin_service.dart';

// SERVICES
final menuAdminServiceProvider = Provider((ref) => MenuAdminService());
final rolAdminServiceProvider = Provider((ref) => RolAdminService());

// MENUS - AGREGADO .autoDispose
final menusAdminProvider = FutureProvider.autoDispose<List<MenuApp>>((
  ref,
) async {
  return ref.watch(menuAdminServiceProvider).getMenus();
});

// ROLES - AGREGADO .autoDispose
final rolesAdminProvider = FutureProvider.autoDispose<List<Rol>>((ref) async {
  return ref.watch(rolAdminServiceProvider).getRoles();
});
