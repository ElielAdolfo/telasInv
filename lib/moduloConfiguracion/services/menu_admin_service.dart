import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/menu_item.dart';

class MenuAdminService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _ref =>
      _db.collection(Env.col('menus'));

  Future<List<MenuApp>> getMenus() async {
    final snap = await _ref
        .where('eliminado', isEqualTo: false)
        .orderBy('ordenBase')
        .get();

    return snap.docs.map((d) => MenuApp.fromJson(d.data())).toList();
  }

  // Crear o Actualizar
  Future<void> saveMenu(MenuApp menu) async {
    if (menu.id.isEmpty) {
      // Crear nuevo con ID autogenerado
      final newDoc = _ref.doc();
      final newMenu = menu.copyWith(id: newDoc.id);
      await newDoc.set(newMenu.toJson());
    } else {
      await _ref.doc(menu.id).update(menu.toJson());
    }
  }

  // Eliminación Lógica
  Future<void> deleteMenuLogic(String id) async {
    await _ref.doc(id).update({'eliminado': true});
  }
}
