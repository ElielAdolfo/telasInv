import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/services/relaciones_service.dart';

// Service Provider
final relacionesServiceProvider = Provider((ref) => RelacionesService());

// Lista de Roles
final rolesProvider = FutureProvider<List<Rol>>((ref) async {
  return ref.read(relacionesServiceProvider).obtenerRoles();
});

// Lista de Menus
final menusProvider = FutureProvider<List<MenuApp>>((ref) async {
  return ref.read(relacionesServiceProvider).obtenerMenus();
});
