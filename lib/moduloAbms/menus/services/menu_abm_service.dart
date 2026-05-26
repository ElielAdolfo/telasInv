import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/menu_item.dart';

class MenuAbmService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<MenuApp>> streamMenus() {
    return _db
        .collection(Env.col('menus'))
        .orderBy('ordenBase', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MenuApp.fromJson({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> guardarMenu(MenuApp menu) async {
    final ref = _db.collection(Env.col('menus')).doc(menu.id);
    if (menu.id.isEmpty) {
      // Crear nuevo con ID autogenerado
      final newDoc = _db.collection(Env.col('menus')).doc();
      await newDoc.set(menu.toJson()..['id'] = newDoc.id);
    } else {
      await ref.set(menu.toJson(), SetOptions(merge: true));
    }
  }

  Future<void> eliminarMenu(String id) async {
    await _db.collection(Env.col('menus')).doc(id).delete();
  }
}
