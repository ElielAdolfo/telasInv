import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'env.dart';

class SystemInitializer {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    final configRef = _db.collection(Env.col('system')).doc('config');

    final configSnap = await configRef.get();

    if (configSnap.exists && configSnap.data()?['initialized'] == true) {
      print('ℹ️ Sistema ya inicializado');
      return;
    }

    print('🚀 Inicializando sistema...');

    try {
      await _seedEmpresaAdmin();

      await _seedMenus();

      await _seedRoles();

      await _seedAdminUser();

      await configRef.set({
        'initialized': true,
        'version': 2,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Sistema inicializado');
    } catch (e) {
      print('❌ Error initialize: $e');
    }
  }

  /// EMPRESA ADMIN
  Future<void> _seedEmpresaAdmin() async {
    final empresaRef = _db.collection(Env.col('empresas')).doc('empAdmin');

    await empresaRef.set({
      'nombre': 'Empresa Administradora',
      'activo': true,
      'eliminado': false,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('✅ Empresa admin creada');
  }

  /// MENUS
  Future<void> _seedMenus() async {
    final batch = _db.batch();

    final menusRef = _db.collection(Env.col('menus'));

    final menus = [
      {
        'id': 'inventario',
        'nombre': 'Inventario',
        'icono': 'inventory',
        'ruta': '/inventario',
        'ordenBase': 1,
      },
      {
        'id': 'ventas',
        'nombre': 'Ventas',
        'icono': 'point_of_sale',
        'ruta': '/ventas',
        'ordenBase': 2,
      },
      {
        'id': 'lotes',
        'nombre': 'Lotes',
        'icono': 'inventory_2',
        'ruta': '/lotes',
        'ordenBase': 3,
      },
      {
        'id': 'precios',
        'nombre': 'Precios',
        'icono': 'price_change',
        'ruta': '/precios',
        'ordenBase': 4,
      },
      {
        'id': 'relaciones',
        'nombre': 'Relaciones',
        'icono': 'settings',
        'ruta': '/relaciones',
        'ordenBase': 5,
      },
      {
        'id': 'usuarios',
        'nombre': 'Rol, Menú',
        'icono': 'people_alt',
        'ruta': '/usuarios',
        'ordenBase': 11,
      },
      {
        'id': 'ver_json',
        'nombre': 'Ver JSON',
        'icono': 'data_object',
        'ruta': '/ver-json',
        'ordenBase': 12,
      },

      // NUEVOS MENÚS PARA ABM
      {
        'id': 'abm_menus',
        'nombre': 'ABM Menús',
        'icono': 'menu_open',
        'ruta': '/abm-menus',
        'ordenBase': 20,
      },
      {
        'id': 'abm_roles',
        'nombre': 'ABM Roles',
        'icono': 'admin_panel_settings',
        'ruta': '/abm-roles',
        'ordenBase': 21,
      },
    ];

    for (final menu in menus) {
      batch.set(menusRef.doc(menu['id'] as String), {
        ...menu,
        'activo': true,
        'visible': true,
        'eliminado': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    print('✅ Menús creados');
  }

  /// ROLES
  Future<void> _seedRoles() async {
    final batch = _db.batch();

    final rolesRef = _db.collection(Env.col('roles'));

    final roles = [
      {
        'id': 'superAdmin',
        'nombre': 'Super Administrador',
        'menusPermitidos': [
          'relaciones',
          'usuarios',
          'ver_json',
          'abm_menus', // NUEVO
          'abm_roles',
        ],
      },
      {
        'id': 'admin',
        'nombre': 'Administrador',
        'menusPermitidos': [
          'inventario',
          'lotes',
          'precios',
          'relaciones',
          'ventas',
          'usuarios',
          'ver_json',
        ],
      },
      {
        'id': 'vendedor',
        'nombre': 'Vendedor',
        'menusPermitidos': ['ventas'],
      },
    ];

    for (final rol in roles) {
      batch.set(rolesRef.doc(rol['id'] as String), {
        ...rol,
        'activo': true,
        'eliminado': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    print('✅ Roles creados');
  }

  /// ADMIN
  Future<void> _seedAdminUser() async {
    const email = 'admin@admin.com';
    const password = '123456Aa';

    UserCredential? credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Auth admin creado');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final login = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        credential = login;
      } else {
        rethrow;
      }
    }

    final uid = credential.user!.uid;

    await _db.collection(Env.col('usuarios')).doc(uid).set({
      'uid': uid,
      'nombre': 'super usuario',
      'email': email,

      /// NUEVA ESTRUCTURA
      'empresas': [
        {
          'empresaId': 'empAdmin',
          'rolesIds': ['superAdmin', 'admin'], // <--- ASIGNAMOS DOS ROLES AQUÍ
          'sucursalesIds': [],
        },
      ],

      'activo': true,
      'eliminado': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _auth.signOut();

    print('✅ Usuario admin creado');
  }
}
