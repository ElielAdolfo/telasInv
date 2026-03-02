import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

class InventarioProvider extends ChangeNotifier {
  final StorageRepository _repository;
  
  List<RolloModel> _rollos = [];
  List<EmpresaModel> _empresas = [];
  List<SucursalModel> _sucursales = [];
  List<ColorTelaModel> _colores = [];
  List<TipoTelaModel> _tiposTela = [];
  Map<String, String> _codigosPorEmpresa = {};
  
  String _busqueda = '';
  String _filtroSucursal = '';
  String _filtroEmpresa = '';
  String _filtroColor = '';
  String _filtroTipoTela = '';
  
  bool _isLoading = false;
  String? _error;
  final Set<String> _rollosSeleccionados = {};

  InventarioProvider({required StorageRepository repository}) : _repository = repository;

  List<RolloModel> get rollos => _rollos;
  List<EmpresaModel> get empresas => _empresas;
  List<SucursalModel> get sucursales => _sucursales;
  List<ColorTelaModel> get colores => _colores;
  List<TipoTelaModel> get tiposTela => _tiposTela;
  Map<String, String> get codigosPorEmpresa => _codigosPorEmpresa;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get busqueda => _busqueda;
  String get filtroSucursal => _filtroSucursal;
  String get filtroEmpresa => _filtroEmpresa;
  String get filtroColor => _filtroColor;
  String get filtroTipoTela => _filtroTipoTela;
  Set<String> get rollosSeleccionados => Set.unmodifiable(_rollosSeleccionados);
  int get cantidadSeleccionados => _rollosSeleccionados.length;
  int get totalRollos => _rollos.length;
  double get metrajeTotal => _rollos.fold(0.0, (sum, r) => sum + r.metraje);
  int get totalEmpresas => _rollos.map((r) => r.empresa).toSet().length;
  int get totalSucursales => _rollos.where((r) => r.sucursal.isNotEmpty).map((r) => r.sucursal).toSet().length;
  int get totalColores => _rollos.map((r) => r.color).toSet().length;

  List<GrupoRollosModel> get gruposFiltrados {
    final grupos = <String, GrupoRollosModel>{};
    for (var rollo in _rollos) {
      if (_filtroSucursal.isNotEmpty) {
        if (_filtroSucursal == '__sin__') {
          if (rollo.sucursal.isNotEmpty) continue;
        } else {
          if (rollo.sucursal != _filtroSucursal) continue;
        }
      }
      if (_filtroEmpresa.isNotEmpty && rollo.empresa != _filtroEmpresa) continue;
      if (_filtroColor.isNotEmpty && rollo.color != _filtroColor) continue;
      if (_filtroTipoTela.isNotEmpty && rollo.tipoTela != _filtroTipoTela) continue;
      
      if (_busqueda.isNotEmpty) {
        final busquedaLower = _busqueda.toLowerCase();
        if (!rollo.color.toLowerCase().contains(busquedaLower) &&
            !rollo.codigoColor.toLowerCase().contains(busquedaLower) &&
            !rollo.empresa.toLowerCase().contains(busquedaLower) &&
            !rollo.tipoTela.toLowerCase().contains(busquedaLower)) continue;
      }
      
      final key = rollo.grupoKey;
      if (!grupos.containsKey(key)) {
        grupos[key] = GrupoRollosModel(
          color: rollo.color, empresa: rollo.empresa, codigoColor: rollo.codigoColor,
          tipoTela: rollo.tipoTela, rollos: [], metrajeTotal: 0, sucursales: {},
        );
      }
      grupos[key]!.rollos.add(rollo);
      grupos[key] = grupos[key]!.copyWith(
        metrajeTotal: grupos[key]!.metrajeTotal + rollo.metraje,
        sucursales: {...grupos[key]!.sucursales, if (rollo.sucursal.isNotEmpty) rollo.sucursal},
      );
    }
    return grupos.values.toList();
  }

  Future<void> cargarDatos() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final futures = await Future.wait([
        _repository.getAllRollos(), _repository.getAllEmpresas(), _repository.getAllSucursales(),
        _repository.getAllColores(), _repository.getAllTiposTela(), _repository.getAllCodigos(),
      ]);
      _rollos = futures[0] as List<RolloModel>;
      _empresas = futures[1] as List<EmpresaModel>;
      _sucursales = futures[2] as List<SucursalModel>;
      _colores = futures[3] as List<ColorTelaModel>;
      _tiposTela = futures[4] as List<TipoTelaModel>;
      _codigosPorEmpresa = futures[5] as Map<String, String>;
      _isLoading = false; notifyListeners();
    } catch (e) { _error = e.toString(); _isLoading = false; notifyListeners(); }
  }

  void setBusqueda(String value) { _busqueda = value; notifyListeners(); }
  void setFiltroSucursal(String value) { _filtroSucursal = value; notifyListeners(); }
  void setFiltroEmpresa(String value) { _filtroEmpresa = value; notifyListeners(); }
  void setFiltroColor(String value) { _filtroColor = value; notifyListeners(); }
  void setFiltroTipoTela(String value) { _filtroTipoTela = value; notifyListeners(); }
  void limpiarFiltros() { _busqueda = ''; _filtroSucursal = ''; _filtroEmpresa = ''; _filtroColor = ''; _filtroTipoTela = ''; notifyListeners(); }

  void toggleSeleccion(String rolloId) {
    if (_rollosSeleccionados.contains(rolloId)) _rollosSeleccionados.remove(rolloId);
    else _rollosSeleccionados.add(rolloId);
    notifyListeners();
  }
  void limpiarSeleccion() { _rollosSeleccionados.clear(); notifyListeners(); }
  bool estaSeleccionado(String rolloId) => _rollosSeleccionados.contains(rolloId);
  double get metrajeSeleccionados => _rollos.where((r) => _rollosSeleccionados.contains(r.id)).fold(0.0, (sum, r) => sum + r.metraje);

  Future<void> guardarRollo(RolloModel rollo) async {
    await _repository.saveRollo(rollo);
    _rollos.add(rollo);
    final key = '${rollo.empresa}_${rollo.color}';
    _codigosPorEmpresa[key] = rollo.codigoColor;
    await _repository.saveCodigoPorEmpresa(rollo.empresa, rollo.color, rollo.codigoColor);
    notifyListeners();
  }

  Future<void> guardarRollos(List<RolloModel> nuevosRollos) async {
    await _repository.saveRollos(nuevosRollos);
    _rollos.addAll(nuevosRollos);
    for (var rollo in nuevosRollos) {
      final key = '${rollo.empresa}_${rollo.color}';
      _codigosPorEmpresa[key] = rollo.codigoColor;
      await _repository.saveCodigoPorEmpresa(rollo.empresa, rollo.color, rollo.codigoColor);
    }
    notifyListeners();
  }

  Future<void> actualizarRollo(RolloModel rollo) async {
    await _repository.updateRollo(rollo);
    final index = _rollos.indexWhere((r) => r.id == rollo.id);
    if (index != -1) _rollos[index] = rollo;
    notifyListeners();
  }

  Future<void> actualizarSucursalRollo(String rolloId, String nuevaSucursal) async {
    final index = _rollos.indexWhere((r) => r.id == rolloId);
    if (index == -1) return;
    final rollo = _rollos[index];
    final historial = List<HistorialMovimiento>.from(rollo.historial);
    historial.add(HistorialMovimiento(
      tipo: 'edicion',
      sucursalOrigen: rollo.sucursal.isEmpty ? 'Sin sucursal' : rollo.sucursal,
      sucursalDestino: nuevaSucursal.isEmpty ? 'Sin sucursal' : nuevaSucursal,
      fecha: DateTime.now(),
    ));
    await actualizarRollo(rollo.copyWith(sucursal: nuevaSucursal, historial: historial));
  }

  Future<void> eliminarRollo(String id) async {
    await _repository.deleteRollo(id);
    _rollos.removeWhere((r) => r.id == id);
    _rollosSeleccionados.remove(id);
    notifyListeners();
  }

  Future<void> moverRollosSeleccionados(String destino) async {
    for (var id in _rollosSeleccionados) await actualizarSucursalRollo(id, destino);
    limpiarSeleccion();
  }

  Future<void> guardarEmpresa(EmpresaModel empresa) async { await _repository.saveEmpresa(empresa); _empresas.add(empresa); notifyListeners(); }
  bool existeEmpresa(String nombre) => _empresas.any((e) => e.nombre.toLowerCase() == nombre.toLowerCase());
  Future<void> updateEmpresa(EmpresaModel empresa) async { await _repository.updateEmpresa(empresa); final i = _empresas.indexWhere((e) => e.id == empresa.id); if (i != -1) _empresas[i] = empresa; notifyListeners(); }
  Future<void> deleteEmpresa(String id) async { await _repository.deleteEmpresa(id); _empresas.removeWhere((e) => e.id == id); notifyListeners(); }

  Future<void> guardarSucursal(SucursalModel sucursal) async { await _repository.saveSucursal(sucursal); _sucursales.add(sucursal); notifyListeners(); }
  bool existeSucursal(String nombre) => _sucursales.any((s) => s.nombre.toLowerCase() == nombre.toLowerCase());
  SucursalModel? getSucursalByNombre(String nombre) { try { return _sucursales.firstWhere((s) => s.nombre == nombre); } catch (_) { return null; } }
  Future<void> updateSucursal(SucursalModel sucursal) async { await _repository.updateSucursal(sucursal); final i = _sucursales.indexWhere((s) => s.id == sucursal.id); if (i != -1) _sucursales[i] = sucursal; notifyListeners(); }
  Future<void> deleteSucursal(String id) async { await _repository.deleteSucursal(id); _sucursales.removeWhere((s) => s.id == id); notifyListeners(); }

  Future<void> guardarColor(ColorTelaModel color) async { await _repository.saveColor(color); _colores.add(color); notifyListeners(); }
  bool existeColor(String nombre) => _colores.any((c) => c.nombre.toLowerCase() == nombre.toLowerCase());
  ColorTelaModel? getColorByNombre(String nombre) { try { return _colores.firstWhere((c) => c.nombre == nombre); } catch (_) { return null; } }
  Future<void> updateColor(ColorTelaModel color) async { await _repository.updateColor(color); final i = _colores.indexWhere((c) => c.id == color.id); if (i != -1) _colores[i] = color; notifyListeners(); }
  Future<void> deleteColor(String id) async { await _repository.deleteColor(id); _colores.removeWhere((c) => c.id == id); notifyListeners(); }

  Future<void> guardarTipoTela(TipoTelaModel tipoTela) async { await _repository.saveTipoTela(tipoTela); _tiposTela.add(tipoTela); notifyListeners(); }
  bool existeTipoTela(String nombre) => _tiposTela.any((t) => t.nombre.toLowerCase() == nombre.toLowerCase());
  Future<void> updateTipoTela(TipoTelaModel tipoTela) async { await _repository.updateTipoTela(tipoTela); final i = _tiposTela.indexWhere((t) => t.id == tipoTela.id); if (i != -1) _tiposTela[i] = tipoTela; notifyListeners(); }
  Future<void> deleteTipoTela(String id) async { await _repository.deleteTipoTela(id); _tiposTela.removeWhere((t) => t.id == id); notifyListeners(); }

  String? getCodigoSugerido(String empresa, String color) => _codigosPorEmpresa['$empresa\_$color'];
  List<RolloModel> getRollosGrupo(String color, String empresa, String codigoColor, String tipoTela) =>
    _rollos.where((r) => r.color == color && r.empresa == empresa && r.codigoColor == codigoColor && r.tipoTela == tipoTela).toList();
  Future<void> limpiarTodo() async { await _repository.clearAll(); await cargarDatos(); }
}
