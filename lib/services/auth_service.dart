import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/config/env.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Obtener usuario actual (si ya está logueado)
  Future<Usuario?> getUsuarioActual() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return await _fetchUserData(user.uid);
  }

  // Login
  Future<Usuario?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (cred.user == null) return null;

      // Sincronizar datos con Firestore (por si cambiaron roles)
      return await _fetchUserData(cred.user!.uid);
    } catch (e) {
      print("Error login: $e");
      return null;
    }
  }

  // Registro de usuarios
  Future<String?> register({
    required String email,
    required String password,
    required String nombre,
    String rol = 'VENDEDOR',
  }) async {
    try {
      // 1. Crear en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (cred.user == null) return "Error al crear usuario";

      // 2. Guardar en Firestore
      final usuario = Usuario(
        id: cred.user!.uid,
        email: email.trim(),
        nombre: nombre.trim(),
        rol: rol,
      );

      await _firestore
          .collection(Env.col('users'))
          .doc(usuario.id)
          .set(usuario.toJson());

      return null; // Null significa éxito
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() => _auth.signOut();

  // --- LÓGICA DEL ADMIN AUTOMÁTICO ---

  Future<void> seedAdminUser() async {
    const adminEmail = "admin@admin.com";
    const adminPass = "123456Aa";

    try {
      // Verificar si ya existe en Firestore (más rápido que verificar en Auth)
      final query = await _firestore
          .collection(Env.col('users'))
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("🌱 Creando usuario Admin inicial...");

        // Intentar crear en Auth
        try {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPass,
          );

          // Crear en Firestore
          final admin = Usuario(
            id: cred.user!.uid,
            email: adminEmail,
            nombre: "Administrador",
            rol: 'ADMIN',
          );
          await _firestore
              .collection(Env.col('users'))
              .doc(admin.id)
              .set(admin.toJson());
          print("✅ Admin creado exitosamente");
        } on FirebaseAuthException catch (e) {
          // Si el error es "email-already-in-use", significa que alguien intentó crearlo antes
          // pero no está en nuestra DB. Intentamos recuperar el UID.
          if (e.code == 'email-already-in-use') {
            print("⚠️ Admin ya existía en Auth, sincronizando DB...");
            // Nota: Para obtener el UID de un usuario existente sin login es complejo.
            // Lo ideal es que el Admin ya se haya logueado alguna vez.
            // Por seguridad, si el email ya existe, simplemente ignoramos.
          } else {
            print("Error semilla Admin: $e");
          }
        }
      }
    } catch (e) {
      print("Error verificando Admin: $e");
    }
  }

  // Helper para leer datos de Firestore
  Future<Usuario?> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection(Env.col('users')).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return Usuario.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
