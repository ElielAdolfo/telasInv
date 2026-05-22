import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/services/menus_service.dart';

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

      // Sincronizar datos con Firestore
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
    String rolId = 'vendedor', // Por defecto asignamos el ID del rol vendedor
  }) async {
    try {
      // 1. Crear en Firebase Auth
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (cred.user == null) return "Error al crear usuario";

      // 2. Guardar en Firestore con la NUEVA estructura
      final usuario = Usuario(
        id: cred.user!.uid,
        email: email.trim(),
        nombre: nombre.trim(),
        rolesIds: [rolId], // ✅ CAMBIO: Ahora es una lista
        sucursalesIds: [], // ✅ NUEVO: Inicialmente vacío
      );

      // Nota: Asegúrate que el nombre de la colección sea 'usuarios' o 'users'
      // según tu configuración en Env.
      await _firestore
          .collection(Env.col('usuarios')) // Alineado a la recomendación RBAC
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
    // 1. Primero nos aseguramos de que los roles existan
    await _seedRoles();
    const adminEmail = "admin@admin.com";
    const adminPass = "123456Aa";

    try {
      // Verificar si el admin ya existe en Firestore
      final query = await _firestore
          .collection(Env.col('usuarios')) // Alineado a RBAC
          .where('email', isEqualTo: adminEmail)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("🌱 Creando usuario Admin inicial...");

        try {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPass,
          );

          // ✅ ACTUALIZADO: Usa la nueva estructura de listas
          final admin = Usuario(
            id: cred.user!.uid,
            email: adminEmail,
            nombre: "Administrador",
            rolesIds: ['admin'], // ID del rol Admin
            sucursalesIds: [],
          );

          await _firestore
              .collection(Env.col('usuarios'))
              .doc(admin.id)
              .set(admin.toJson());
          print("✅ Admin creado exitosamente");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            print("⚠️ Admin ya existía en Auth.");
          } else {
            print("Error semilla Admin: $e");
          }
        }
      } else {
        print("✅ Usuario Admin ya existe en la base de datos.");
      }
    } catch (e) {
      print("Error verificando Admin: $e");
    }
  }

  // Helper para leer datos de Firestore

  // ✅ NUEVO MÉTODO: Crear roles por defecto
  Future<void> _seedRoles() async {
    final rolesRef = _firestore.collection(Env.col('roles'));

    // Definimos los roles iniciales según tu requerimiento
    final List<Rol> defaultRoles = [
      Rol(
        id: 'admin',
        nombre: 'Administrador',
        activo: true,
        menusPermitidos: [
          'inventario',
          'lotes',
          'precios',
          'relaciones',
          'ventas',
          'consultas',
          'configuracion',
          'usuarios',
          'roles',
          'sucursales',
        ],
      ),
      Rol(
        id: 'responsable_sucursal',
        nombre: 'Responsable de Sucursal',
        activo: true,
        menusPermitidos: [
          'inventario',
          'lotes',
          'precios',
          'relaciones',
          'ventas',
        ],
      ),
      Rol(
        id: 'vendedor',
        nombre: 'Vendedor',
        activo: true,
        menusPermitidos: ['ventas'],
      ),
      Rol(
        id: 'consultas',
        nombre: 'Consultas',
        activo: true,
        menusPermitidos: ['consultas', 'reportes'],
      ),
    ];

    for (var rol in defaultRoles) {
      final doc = rolesRef.doc(rol.id);
      final snap = await doc.get();

      // Solo creamos si no existe
      if (!snap.exists) {
        await doc.set(rol.toJson());
        print("🌱 Rol creado: ${rol.nombre}");
      }
    }
  }

  Future<Usuario?> _fetchUserData(String uid) async {
    try {
      // Asegúrate que apunte a la misma colección que usas para guardar
      final doc = await _firestore
          .collection(Env.col('usuarios'))
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return Usuario.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetch user: $e");
      return null;
    }
  }
}
