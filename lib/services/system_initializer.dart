// lib/services/system_initializer.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';

class SystemInitializer {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialize() async {
    // 1. Referencia al documento de control
    final configRef = _db.collection(Env.col('system')).doc('config');
    final configSnap = await configRef.get();

    // 2. Si ya existe y está inicializado, no hacemos nada
    if (configSnap.exists && configSnap.data()?['initialized'] == true) {
      print('ℹ️ Sistema ya inicializado. Omitiendo seeds.');
      return;
    }

    print('🚀 Inicializando sistema por primera vez...');

    try {
      // 3. Ejecutar creación de datos base en bloque
      await _seedMenus();
      await _seedRoles();
      // Opcional: Crear usuario admin inicial si no existe
      // await _seedAdminUser();

      // 4. Marcar como inicializado
      await configRef.set({
        'initialized': true,
        'version': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Sistema inicializado correctamente.');
    } catch (e) {
      print('❌ Error inicializando sistema: $e');
    }
  }

  Future<void> _seedMenus() async {
    final batch = _db.batch();
    final menusRef = _db.collection(Env.col('menus'));

    // Datos extraídos de tu JSON
    final menus = [
      {
        'id': 'inventario',
        'nombre': 'Inventario',
        'icono': 'inventory',
        'ruta': '/inventario',
        'ordenBase': 1,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'ventas',
        'nombre': 'Ventas',
        'icono': 'point_of_sale',
        'ruta': '/ventas',
        'ordenBase': 2,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'lotes',
        'nombre': 'Lotes',
        'icono': 'inventory_2',
        'ruta': '/lotes',
        'ordenBase': 3,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'precios',
        'nombre': 'Precios',
        'icono': 'price_change',
        'ruta': '/precios',
        'ordenBase': 4,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'relaciones',
        'nombre': 'Relaciones',
        'icono': 'settings',
        'ruta': '/relaciones',
        'ordenBase': 5,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'usuarios',
        'nombre': 'Rol, Menú',
        'icono': 'people_alt',
        'ruta': '/usuarios',
        'ordenBase': 11,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
      {
        'id': 'ver_json',
        'nombre': 'Ver JSON',
        'icono': 'data_object',
        'ruta': '/ver-json',
        'ordenBase': 12,
        'activo': true,
        'visible': true,
        'eliminado': false,
      },
    ];

    for (var menu in menus) {
      final docRef = menusRef.doc(menu['id'] as String);
      // Usamos SetOptions(merge: true) para no borrar campos si ya existieran
      batch.set(docRef, menu, SetOptions(merge: true));
    }

    await batch.commit();
    print(' -> Menús creados/verificados.');
  }

  Future<void> _seedRoles() async {
    final batch = _db.batch();
    final rolesRef = _db.collection(Env.col('roles'));

    // Datos extraídos de tu JSON
    final roles = [
      {
        'id': 'admin',
        'nombre': 'Administrador',
        'activo': true,
        'eliminado': false,
        'menusPermitidos': [
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
          'ver_json',
        ],
      },
      {
        'id': 'vendedor',
        'nombre': 'Vendedor',
        'activo': true,
        'eliminado': false,
        'menusPermitidos': ['ventas'],
      },
      {
        'id': 'responsable_sucursal',
        'nombre': 'Responsable de Sucursal',
        'activo': true,
        'eliminado': false,
        'menusPermitidos': [
          'inventario',
          'lotes',
          'precios',
          'relaciones',
          'ventas',
        ],
      },
      {
        'id': 'consultas',
        'nombre': 'Consultas',
        'activo': true,
        'eliminado': false,
        'menusPermitidos': ['consultas', 'reportes'],
      },
    ];

    for (var rol in roles) {
      final docRef = rolesRef.doc(rol['id'] as String);
      batch.set(docRef, rol, SetOptions(merge: true));
    }

    await batch.commit();
    print(' -> Roles creados/verificados.');
  }
}
