import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';
import 'storage_repository.dart';

class LocalStorageRepository implements StorageRepository {
  static Database? _database;
  static const String _dbName = 'inventario_rollos.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE rollos (
        id TEXT PRIMARY KEY,
        sucursal TEXT,
        empresa TEXT NOT NULL,
        color TEXT NOT NULL,
        codigoColor TEXT NOT NULL,
        tipoTela TEXT,
        metraje REAL NOT NULL,
        fecha TEXT,
        notas TEXT,
        fechaCreacion TEXT NOT NULL,
        historial TEXT,
        syncPending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('CREATE INDEX idx_rollos_empresa ON rollos(empresa)');
    await db.execute('CREATE INDEX idx_rollos_color ON rollos(color)');
    await db.execute('CREATE INDEX idx_rollos_sucursal ON rollos(sucursal)');
    await db.execute('CREATE INDEX idx_rollos_codigo ON rollos(codigoColor)');
    await db.execute('CREATE INDEX idx_rollos_tipo ON rollos(tipoTela)');

    await db.execute('''
      CREATE TABLE empresas (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        fechaCreacion TEXT NOT NULL,
        syncPending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sucursales (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        syncPending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE colores (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        hex TEXT NOT NULL,
        fechaCreacion TEXT NOT NULL,
        syncPending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE tipos_tela (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL UNIQUE,
        fechaCreacion TEXT NOT NULL,
        syncPending INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE codigos_empresa (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        empresa TEXT NOT NULL,
        color TEXT NOT NULL,
        codigo TEXT NOT NULL,
        UNIQUE(empresa, color)
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    final empresas = [
      {'id': 'emp_1', 'nombre': 'Textiles del Norte'},
      {'id': 'emp_2', 'nombre': 'Telas Premium'},
      {'id': 'emp_3', 'nombre': 'Fabrica Central'},
      {'id': 'emp_4', 'nombre': 'Textiles Sur'},
    ];

    for (var e in empresas) {
      await db.insert('empresas', {
        ...e,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'syncPending': 0,
      });
    }

    final sucursales = [
      {'id': 'suc_1', 'nombre': 'Sucursal Central', 'color': '#3b82f6'},
      {'id': 'suc_2', 'nombre': 'Sucursal Norte', 'color': '#10b981'},
      {'id': 'suc_3', 'nombre': 'Sucursal Sur', 'color': '#f59e0b'},
      {'id': 'suc_4', 'nombre': 'Bodega Principal', 'color': '#8b5cf6'},
    ];

    for (var s in sucursales) {
      await db.insert('sucursales', {
        ...s,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'syncPending': 0,
      });
    }

    final colores = [
      {'id': 'col_1', 'nombre': 'Azul Marino', 'hex': '#1e3a5f'},
      {'id': 'col_2', 'nombre': 'Rojo Escarlata', 'hex': '#dc2626'},
      {'id': 'col_3', 'nombre': 'Verde Bosque', 'hex': '#166534'},
      {'id': 'col_4', 'nombre': 'Negro', 'hex': '#171717'},
      {'id': 'col_5', 'nombre': 'Blanco', 'hex': '#f5f5f5'},
      {'id': 'col_6', 'nombre': 'Gris Piedra', 'hex': '#6b7280'},
      {'id': 'col_7', 'nombre': 'Beige Arena', 'hex': '#d4b896'},
      {'id': 'col_8', 'nombre': 'Violeta', 'hex': '#7c3aed'},
    ];

    for (var c in colores) {
      await db.insert('colores', {
        ...c,
        'fechaCreacion': DateTime.now().toIso8601String(),
        'syncPending': 0,
      });
    }

    final tiposTela = [
      'Piel de Sirena', 'Razo', 'Magitex', 'Crepé', 'Chifón',
      'Seda Artificial', 'Satén', 'Tela Drill', 'Lino', 'Algodón',
      'Poliéster', 'Jersey', 'Franela', 'Terciopelo', 'Oxford',
    ];

    for (var i = 0; i < tiposTela.length; i++) {
      await db.insert('tipos_tela', {
        'id': 'tip_${i + 1}',
        'nombre': tiposTela[i],
        'fechaCreacion': DateTime.now().toIso8601String(),
        'syncPending': 0,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ROLLOS
  @override
  Future<List<RolloModel>> getAllRollos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('rollos');
    return maps.map((map) => _mapToRollo(map)).toList();
  }

  @override
  Future<RolloModel?> getRolloById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'rollos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToRollo(maps.first);
  }

  @override
  Future<void> saveRollo(RolloModel rollo) async {
    final db = await database;
    await db.insert('rollos', _rolloToMap(rollo), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> saveRollos(List<RolloModel> rollos) async {
    final db = await database;
    final batch = db.batch();
    for (var rollo in rollos) {
      batch.insert('rollos', _rolloToMap(rollo), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> updateRollo(RolloModel rollo) async {
    final db = await database;
    await db.update('rollos', {..._rolloToMap(rollo), 'syncPending': 1}, where: 'id = ?', whereArgs: [rollo.id]);
  }

  @override
  Future<void> deleteRollo(String id) async {
    final db = await database;
    await db.delete('rollos', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteRollos(List<String> ids) async {
    final db = await database;
    final batch = db.batch();
    for (var id in ids) {
      batch.delete('rollos', where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  // EMPRESAS
  @override
  Future<List<EmpresaModel>> getAllEmpresas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('empresas', orderBy: 'nombre ASC');
    return maps.map((map) => EmpresaModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveEmpresa(EmpresaModel empresa) async {
    final db = await database;
    await db.insert('empresas', empresa.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateEmpresa(EmpresaModel empresa) async {
    final db = await database;
    await db.update('empresas', empresa.toMap(), where: 'id = ?', whereArgs: [empresa.id]);
  }

  @override
  Future<void> deleteEmpresa(String id) async {
    final db = await database;
    await db.delete('empresas', where: 'id = ?', whereArgs: [id]);
  }

  // SUCURSALES
  @override
  Future<List<SucursalModel>> getAllSucursales() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('sucursales', orderBy: 'nombre ASC');
    return maps.map((map) => SucursalModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveSucursal(SucursalModel sucursal) async {
    final db = await database;
    await db.insert('sucursales', sucursal.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateSucursal(SucursalModel sucursal) async {
    final db = await database;
    await db.update('sucursales', sucursal.toMap(), where: 'id = ?', whereArgs: [sucursal.id]);
  }

  @override
  Future<void> deleteSucursal(String id) async {
    final db = await database;
    await db.delete('sucursales', where: 'id = ?', whereArgs: [id]);
  }

  // COLORES
  @override
  Future<List<ColorTelaModel>> getAllColores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('colores', orderBy: 'nombre ASC');
    return maps.map((map) => ColorTelaModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveColor(ColorTelaModel color) async {
    final db = await database;
    await db.insert('colores', color.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateColor(ColorTelaModel color) async {
    final db = await database;
    await db.update('colores', color.toMap(), where: 'id = ?', whereArgs: [color.id]);
  }

  @override
  Future<void> deleteColor(String id) async {
    final db = await database;
    await db.delete('colores', where: 'id = ?', whereArgs: [id]);
  }

  // TIPOS DE TELA
  @override
  Future<List<TipoTelaModel>> getAllTiposTela() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tipos_tela', orderBy: 'nombre ASC');
    return maps.map((map) => TipoTelaModel.fromMap(map)).toList();
  }

  @override
  Future<void> saveTipoTela(TipoTelaModel tipoTela) async {
    final db = await database;
    await db.insert('tipos_tela', tipoTela.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateTipoTela(TipoTelaModel tipoTela) async {
    final db = await database;
    await db.update('tipos_tela', tipoTela.toMap(), where: 'id = ?', whereArgs: [tipoTela.id]);
  }

  @override
  Future<void> deleteTipoTela(String id) async {
    final db = await database;
    await db.delete('tipos_tela', where: 'id = ?', whereArgs: [id]);
  }

  // CODIGOS
  @override
  Future<String?> getCodigoPorEmpresa(String empresa, String color) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'codigos_empresa',
      where: 'empresa = ? AND color = ?',
      whereArgs: [empresa, color],
    );
    if (maps.isEmpty) return null;
    return maps.first['codigo'] as String;
  }

  @override
  Future<void> saveCodigoPorEmpresa(String empresa, String color, String codigo) async {
    final db = await database;
    await db.insert(
      'codigos_empresa',
      {'empresa': empresa, 'color': color, 'codigo': codigo},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, String>> getAllCodigos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('codigos_empresa');
    final result = <String, String>{};
    for (var map in maps) {
      final key = '${map['empresa']}_${map['color']}';
      result[key] = map['codigo'] as String;
    }
    return result;
  }

  // SINCRONIZACION
  @override
  Future<void> sync() async {
    final db = await database;
    await db.update('rollos', {'syncPending': 0});
    await db.update('empresas', {'syncPending': 0});
    await db.update('sucursales', {'syncPending': 0});
    await db.update('colores', {'syncPending': 0});
    await db.update('tipos_tela', {'syncPending': 0});
  }

  @override
  Future<bool> hasPendingChanges() async {
    final db = await database;
    final tables = ['rollos', 'empresas', 'sucursales', 'colores', 'tipos_tela'];
    for (var table in tables) {
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table WHERE syncPending = 1');
      if ((result.first['count'] as int) > 0) return true;
    }
    return false;
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('rollos');
    await db.delete('empresas');
    await db.delete('sucursales');
    await db.delete('colores');
    await db.delete('tipos_tela');
    await db.delete('codigos_empresa');
    await _insertInitialData(db);
  }

  // HELPERS
  RolloModel _mapToRollo(Map<String, dynamic> map) {
    List<HistorialMovimiento> historial = [];
    if (map['historial'] != null && map['historial'].toString().isNotEmpty) {
      try {
        final List<dynamic> historialJson = json.decode(map['historial']);
        historial = historialJson.map((h) => HistorialMovimiento.fromMap(h)).toList();
      } catch (e) {}
    }

    return RolloModel(
      id: map['id'],
      sucursal: map['sucursal'] ?? '',
      empresa: map['empresa'],
      color: map['color'],
      codigoColor: map['codigoColor'],
      tipoTela: map['tipoTela'] ?? '',
      metraje: map['metraje'],
      fecha: map['fecha'],
      notas: map['notas'],
      fechaCreacion: DateTime.parse(map['fechaCreacion']),
      historial: historial,
    );
  }

  Map<String, dynamic> _rolloToMap(RolloModel rollo) {
    return {
      'id': rollo.id,
      'sucursal': rollo.sucursal,
      'empresa': rollo.empresa,
      'color': rollo.color,
      'codigoColor': rollo.codigoColor,
      'tipoTela': rollo.tipoTela,
      'metraje': rollo.metraje,
      'fecha': rollo.fecha,
      'notas': rollo.notas,
      'fechaCreacion': rollo.fechaCreacion.toIso8601String(),
      'historial': json.encode(rollo.historial.map((h) => h.toMap()).toList()),
      'syncPending': 1,
    };
  }
}
