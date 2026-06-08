import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

class UsuarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usuariosRef =>
      _db.collection(Env.col('usuarios'));

  // ==========================================
  // OBTENER USUARIO POR ID
  // ==========================================
  Future<Usuario?> getUsuarioById(String usuarioId) async {
    try {
      final doc = await _usuariosRef.doc(usuarioId).get();

      if (!doc.exists) {
        return null;
      }

      return Usuario.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      print('❌ getUsuarioById: $e');
      rethrow;
    }
  }

  // ==========================================
  // OBTENER VARIOS USUARIOS POR IDS
  // ==========================================
  Future<List<Usuario>> getUsuariosByIds(List<String> usuariosIds) async {
    try {
      if (usuariosIds.isEmpty) {
        return [];
      }

      final futures = usuariosIds.map((id) => _usuariosRef.doc(id).get());

      final docs = await Future.wait(futures);

      return docs
          .where((doc) => doc.exists)
          .map((doc) => Usuario.fromJson({...doc.data()!, 'id': doc.id}))
          .where((u) => u.activo && !u.eliminado)
          .toList();
    } catch (e) {
      print('❌ getUsuariosByIds: $e');
      rethrow;
    }
  }

  // ==========================================
  // OBTENER USUARIOS PERMITIDOS EMPRESA
  // ==========================================
  Future<List<Usuario>> getUsuariosPermitidos(Empresa empresa) async {
    try {
      final ids = empresa.usuariosPermitidos
          .map((e) => e.usuarioId)
          .toSet()
          .toList();

      return getUsuariosByIds(ids);
    } catch (e) {
      print('❌ getUsuariosPermitidos: $e');
      rethrow;
    }
  }

  // ==========================================
  // OBTENER USUARIOS POR EMPRESA
  // ==========================================
  Future<List<Usuario>> getUsuariosByEmpresaId(String empresaId) async {
    try {
      final snapshot = await _usuariosRef.get();

      return snapshot.docs
          .map((doc) => Usuario.fromJson({...doc.data(), 'id': doc.id}))
          .where(
            (usuario) =>
                usuario.activo &&
                !usuario.eliminado &&
                usuario.empresas.any((e) => e.empresaId == empresaId),
          )
          .toList();
    } catch (e) {
      print('❌ getUsuariosByEmpresaId: $e');
      rethrow;
    }
  }
}
