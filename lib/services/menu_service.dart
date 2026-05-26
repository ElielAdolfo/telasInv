import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/env.dart';
import '../models/menu_item.dart';
import '../models/rol.dart';

class MenuService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Obtener menús permitidos por roles
  Future<List<MenuApp>> getMenusByRoles(List<String> rolesIds) async {
    if (rolesIds.isEmpty) return [];

    // 1. Obtener roles
    final rolesSnapshot = await _db
        .collection(Env.col('roles'))
        .where(FieldPath.documentId, whereIn: rolesIds)
        .get();

    final roles = rolesSnapshot.docs
        .map((doc) => Rol.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    // 2. Obtener IDs únicos de menús
    final Set<String> menuIds = {};

    for (final rol in roles) {
      menuIds.addAll(rol.menusPermitidos);
    }

    if (menuIds.isEmpty) return [];

    // 3. Obtener menús reales desde Firebase
    final menusSnapshot = await _db
        .collection(Env.col('menus'))
        .where(FieldPath.documentId, whereIn: menuIds.toList())
        .get();

    // 4. Convertir y ordenar
    final menus = menusSnapshot.docs
        .map((doc) => MenuApp.fromJson({...doc.data(), 'id': doc.id}))
        .where((m) => m.activo && !m.eliminado && m.visible)
        .toList();

    menus.sort((a, b) => a.ordenBase.compareTo(b.ordenBase));

    return menus;
  }

  Future<List<MenuApp>> getMenusByIds(List<String> menuIds) async {
    if (menuIds.isEmpty) {
      return [];
    }

    final snapshot = await _db
        .collection(Env.col('menus'))
        .where(FieldPath.documentId, whereIn: menuIds)
        .get();

    final menus = snapshot.docs
        .map((doc) => MenuApp.fromJson({...doc.data(), 'id': doc.id}))
        .where((m) => m.activo && !m.eliminado && m.visible)
        .toList();

    menus.sort((a, b) => a.ordenBase.compareTo(b.ordenBase));

    return menus;
  }

  Future<List<MenuApp>> getAllMenus() async {
    final snapshot = await _db
        .collection(Env.col('menus'))
        .orderBy('ordenBase')
        .get();

    return snapshot.docs
        .map((doc) => MenuApp.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }
}
