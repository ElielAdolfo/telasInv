import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';
import '../services/menu_admin_service.dart';
import '../services/rol_admin_service.dart';

// Services Providers
final menuAdminServiceProvider = Provider((ref) => MenuAdminService());
final rolAdminServiceProvider = Provider((ref) => RolAdminService());

// Streams Providers
final menusAdminProvider = StreamProvider<List<MenuApp>>((ref) {
  return ref.watch(menuAdminServiceProvider).streamMenus();
});

final rolesAdminProvider = StreamProvider<List<Rol>>((ref) {
  return ref.watch(rolAdminServiceProvider).streamRoles();
});
