import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/menu_item.dart';

class MenuAbmService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _menusRef =>
      _db.collection(Env.col('menus'));

  /// STREAM MENUS
  /// Realtime sin loading infinito
  Stream<List<MenuApp>> streamMenus() {
    return _menusRef.orderBy('ordenBase', descending: false).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map((doc) => MenuApp.fromJson({...doc.data(), 'id': doc.id}))
          .where((m) => !m.eliminado && m.activo && m.visible)
          .toList();
    });
  }

  /// CREAR / EDITAR MENU
  Future<void> guardarMenu(MenuApp menu, String usuarioId) async {
    try {
      final now = DateTime.now();

      // NUEVO
      if (menu.id.isEmpty) {
        final newDoc = _menusRef.doc();

        final nuevoMenu = menu.copyWith(
          id: newDoc.id,
          eliminado: false,
          fechaCreacion: now,
          usuarioCreadorId: usuarioId,
          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await newDoc.set(nuevoMenu.toJson());

        print('✅ Menú creado: ${nuevoMenu.nombre}');
      }
      // EDITAR
      else {
        final actualizado = menu.copyWith(
          fechaActualizacion: now,
          usuarioModificadorId: usuarioId,
        );

        await _menusRef
            .doc(menu.id)
            .set(actualizado.toJson(), SetOptions(merge: true));

        print('✏️ Menú actualizado: ${menu.nombre}');
      }
    } catch (e) {
      print('❌ guardarMenu: $e');
      rethrow;
    }
  }

  /// ELIMINACION LOGICA
  Future<void> eliminarMenu(String id, String usuarioId) async {
    try {
      final now = Timestamp.now();

      await _menusRef.doc(id).update({
        'eliminado': true,
        'activo': false,
        'fechaEliminacion': now,
        'usuarioEliminadorId': usuarioId,
        'fechaActualizacion': now,
        'usuarioModificadorId': usuarioId,
      });

      print('🗑️ Menú eliminado: $id');
    } catch (e) {
      print('❌ eliminarMenu: $e');
      rethrow;
    }
  }

  /// RESTAURAR MENU
  Future<void> restaurarMenu(String id, String usuarioId) async {
    try {
      final now = Timestamp.now();

      await _menusRef.doc(id).update({
        'eliminado': false,
        'activo': true,
        'fechaEliminacion': null,
        'usuarioEliminadorId': null,
        'fechaActualizacion': now,
        'usuarioModificadorId': usuarioId,
      });

      print('♻️ Menú restaurado');
    } catch (e) {
      print('❌ restaurarMenu: $e');
      rethrow;
    }
  }
}
