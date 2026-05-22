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
}
