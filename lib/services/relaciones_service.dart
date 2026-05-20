import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/usuario.dart';

class RelacionesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- ROLES ---
  Future<List<Rol>> obtenerRoles() async {
    final snap = await _db.collection(Env.col('roles')).get();
    return snap.docs.map((d) => Rol.fromJson(d.data())).toList();
  }

  Future<void> guardarRol(Rol rol) async {
    await _db.collection(Env.col('roles')).doc(rol.id).set(rol.toJson());
  }

  Future<void> eliminarRol(String id) async {
    // Validar si usuarios usan este rol antes de eliminar (lógica de negocio)
    await _db.collection(Env.col('roles')).doc(id).delete();
  }

  // --- MENUS ---
  Future<List<MenuApp>> obtenerMenus() async {
    final snap = await _db
        .collection(Env.col('menus'))
        .orderBy('ordenBase')
        .get();
    return snap.docs.map((d) => MenuApp.fromJson(d.data())).toList();
  }

  // --- USUARIOS (Actualización de relaciones) ---
  Future<void> actualizarUsuarioRelaciones({
    required String usuarioId,
    required List<String> rolesIds,
    required List<String> sucursalesIds,
  }) async {
    await _db.collection(Env.col('usuarios')).doc(usuarioId).update({
      'rolesIds': rolesIds,
      'sucursalesIds': sucursalesIds,
    });
  }

  Future<List<Usuario>> obtenerUsuarios() async {
    final snap = await _db.collection(Env.col('usuarios')).get();
    return snap.docs.map((d) => Usuario.fromJson(d.data())).toList();
  }
}
