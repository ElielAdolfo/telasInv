import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/menu_item.dart';

class MenusService {
  final _db = FirebaseFirestore.instance;

  // ✅ CACHE EN MEMORIA
  static List<MenuApp>? _cacheMenus;

  // ✅ SOLO UNA CONSULTA
  Future<List<MenuApp>> getMenus() async {
    final snap = await _db
        .collection(Env.col('menus'))
        .where('activo', isEqualTo: true)
        .where('visible', isEqualTo: true)
        .orderBy('ordenBase')
        .get();

    return snap.docs.map((doc) {
      final data = doc.data();

      data['id'] = doc.id;

      return MenuApp.fromJson(data);
    }).toList();
  }

  // ✅ LIMPIAR CACHE SI NECESITAS RECARGAR
  static void clearCache() {
    _cacheMenus = null;
  }

  Future<void> seedDefaultMenus() async {
    final ref = _db.collection(Env.col('menus'));

    final snap = await ref.limit(1).get();

    if (snap.docs.isEmpty) {
      final batch = _db.batch();

      final defaults = [
        MenuApp(
          id: 'inventario',
          nombre: 'Inventario',
          icono: 'inventory',
          ruta: '/inventario',
          ordenBase: 1,
        ),

        MenuApp(
          id: 'ventas',
          nombre: 'Ventas',
          icono: 'point_of_sale',
          ruta: '/ventas',
          ordenBase: 2,
        ),

        MenuApp(
          id: 'lotes',
          nombre: 'Lotes',
          icono: 'inventory_2',
          ruta: '/lotes',
          ordenBase: 3,
        ),

        MenuApp(
          id: 'precios',
          nombre: 'Precios',
          icono: 'price_change',
          ruta: '/precios',
          ordenBase: 4,
        ),

        MenuApp(
          id: 'relaciones',
          nombre: 'Relaciones',
          icono: 'settings',
          ruta: '/relaciones',
          ordenBase: 5,
        ),

        MenuApp(
          id: 'roles', // ID importante para coincidir con el permiso del rol
          nombre: 'Gestión de Roles',
          icono: 'admin_panel_settings', // Icono sugerido
          ruta: '/roles',
          ordenBase: 10,
        ),
        MenuApp(
          id: 'usuarios', // ID importante
          nombre: 'Relaciones Usuarios',
          icono: 'people_alt', // Icono sugerido
          ruta: '/usuarios',
          ordenBase: 11,
        ),
        MenuApp(
          id: 'ver_json', // ID nuevo
          nombre: 'Ver JSON',
          icono: 'data_object', // Icono sugerido
          ruta: '/ver-json',
          ordenBase: 12,
        ),
      ];

      for (var menu in defaults) {
        batch.set(ref.doc(menu.id), menu.toJson());
      }

      await batch.commit();

      print("🌱 Menús por defecto creados");
    }
  }
}
