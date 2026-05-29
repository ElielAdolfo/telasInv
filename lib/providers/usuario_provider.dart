import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/usuario.dart';

final usuariosEmpresaProvider = FutureProvider.family<List<Usuario>, String>((
  ref,
  empresaId,
) async {
  if (empresaId.isEmpty) {
    return [];
  }

  final firestore = FirebaseFirestore.instance;

  try {
    final snapshot = await firestore.collection('usuarios').get();

    final usuarios = snapshot.docs
        .map((e) => Usuario.fromJson({...e.data(), 'id': e.id}))
        .where((usuario) {
          if (!usuario.activo || usuario.eliminado) {
            return false;
          }

          /// SOLO usuarios de esa empresa
          return usuario.empresas.any((e) => e.empresaId == empresaId);
        })
        .toList();

    return usuarios;
  } catch (e) {
    throw Exception('No se pudo cargar usuarios: $e');
  }
});
