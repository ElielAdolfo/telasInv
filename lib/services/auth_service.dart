import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';

import '../models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream sesión Firebase
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Obtener usuario actual
  Future<Usuario?> getUsuarioActual() async {
    final user = _auth.currentUser;

    if (user == null) return null;

    final doc = await _firestore
        .collection(Env.col('usuarios'))
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      print('❌ Usuario no existe en Firestore');
      return null;
    }

    print('🔥 Usuario Firestore: ${doc.data()}');

    final usuario = Usuario.fromJson({...doc.data()!, 'id': doc.id});

    /// DEBUG NUEVO
    print(
      '🔥 Empresas usuario: '
      '${usuario.empresas.map((e) => {'empresaId': e.empresaId, 'rolesIds': e.rolesIds}).toList()}',
    );

    return usuario;
  }

  /// LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'Usuario no encontrado';
      }

      if (e.code == 'wrong-password') {
        return 'Contraseña incorrecta';
      }

      return e.message;
    } catch (e) {
      return 'Error desconocido';
    }
  }

  /// REGISTRAR USUARIO
  Future<String?> register({
    required String email,
    required String password,
    required String nombre,

    /// NUEVO
    required String empresaId,
    required String rolId,
  }) async {
    try {
      /// Crear Auth
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      /// Crear Firestore
      await _firestore
          .collection(Env.col('usuarios'))
          .doc(result.user!.uid)
          .set({
            'uid': result.user!.uid,
            'email': email,
            'nombre': nombre,

            /// NUEVA ESTRUCTURA CORREGIDA
            /// Usamos 'rolesIds' (lista) y envolvemos el rolId en corchetes []
            'empresas': [
              {
                'empresaId': empresaId,
                'rolesIds': [rolId],
                'sucursalesIds': [],
              },
            ],

            'activo': true,
            'eliminado': false,
            'createdAt': DateTime.now().toIso8601String(),
          });

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'El correo ya está registrado';
      }

      return e.message;
    } catch (e) {
      print(e);

      return 'Error al registrar';
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}
