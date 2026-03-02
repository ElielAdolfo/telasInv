import '../models/models.dart';
import 'storage_repository.dart';
import 'local_storage_repository.dart';
import 'firebase_storage_repository.dart';

class HybridStorageRepository implements StorageRepository {
  final LocalStorageRepository _localRepo;
  final FirebaseStorageRepository? _firebaseRepo;
  final bool _firebaseEnabled;

  HybridStorageRepository({bool firebaseEnabled = false})
      : _localRepo = LocalStorageRepository(),
        _firebaseRepo = firebaseEnabled ? FirebaseStorageRepository() : null,
        _firebaseEnabled = firebaseEnabled;

  @override Future<List<RolloModel>> getAllRollos() async => await _localRepo.getAllRollos();
  @override Future<RolloModel?> getRolloById(String id) async => await _localRepo.getRolloById(id);
  @override Future<void> saveRollo(RolloModel rollo) async {
    await _localRepo.saveRollo(rollo);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveRollo(rollo).catchError((_) {});
  }
  @override Future<void> saveRollos(List<RolloModel> rollos) async {
    await _localRepo.saveRollos(rollos);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveRollos(rollos).catchError((_) {});
  }
  @override Future<void> updateRollo(RolloModel rollo) async {
    await _localRepo.updateRollo(rollo);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.updateRollo(rollo).catchError((_) {});
  }
  @override Future<void> deleteRollo(String id) async {
    await _localRepo.deleteRollo(id);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteRollo(id).catchError((_) {});
  }
  @override Future<void> deleteRollos(List<String> ids) async {
    await _localRepo.deleteRollos(ids);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteRollos(ids).catchError((_) {});
  }
  @override Future<List<EmpresaModel>> getAllEmpresas() async => await _localRepo.getAllEmpresas();
  @override Future<void> saveEmpresa(EmpresaModel empresa) async {
    await _localRepo.saveEmpresa(empresa);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveEmpresa(empresa).catchError((_) {});
  }
  @override Future<void> updateEmpresa(EmpresaModel empresa) async {
    await _localRepo.updateEmpresa(empresa);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.updateEmpresa(empresa).catchError((_) {});
  }
  @override Future<void> deleteEmpresa(String id) async {
    await _localRepo.deleteEmpresa(id);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteEmpresa(id).catchError((_) {});
  }
  @override Future<List<SucursalModel>> getAllSucursales() async => await _localRepo.getAllSucursales();
  @override Future<void> saveSucursal(SucursalModel sucursal) async {
    await _localRepo.saveSucursal(sucursal);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveSucursal(sucursal).catchError((_) {});
  }
  @override Future<void> updateSucursal(SucursalModel sucursal) async {
    await _localRepo.updateSucursal(sucursal);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.updateSucursal(sucursal).catchError((_) {});
  }
  @override Future<void> deleteSucursal(String id) async {
    await _localRepo.deleteSucursal(id);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteSucursal(id).catchError((_) {});
  }
  @override Future<List<ColorTelaModel>> getAllColores() async => await _localRepo.getAllColores();
  @override Future<void> saveColor(ColorTelaModel color) async {
    await _localRepo.saveColor(color);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveColor(color).catchError((_) {});
  }
  @override Future<void> updateColor(ColorTelaModel color) async {
    await _localRepo.updateColor(color);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.updateColor(color).catchError((_) {});
  }
  @override Future<void> deleteColor(String id) async {
    await _localRepo.deleteColor(id);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteColor(id).catchError((_) {});
  }
  @override Future<List<TipoTelaModel>> getAllTiposTela() async => await _localRepo.getAllTiposTela();
  @override Future<void> saveTipoTela(TipoTelaModel tipoTela) async {
    await _localRepo.saveTipoTela(tipoTela);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveTipoTela(tipoTela).catchError((_) {});
  }
  @override Future<void> updateTipoTela(TipoTelaModel tipoTela) async {
    await _localRepo.updateTipoTela(tipoTela);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.updateTipoTela(tipoTela).catchError((_) {});
  }
  @override Future<void> deleteTipoTela(String id) async {
    await _localRepo.deleteTipoTela(id);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.deleteTipoTela(id).catchError((_) {});
  }
  @override Future<String?> getCodigoPorEmpresa(String empresa, String color) async => await _localRepo.getCodigoPorEmpresa(empresa, color);
  @override Future<void> saveCodigoPorEmpresa(String empresa, String color, String codigo) async {
    await _localRepo.saveCodigoPorEmpresa(empresa, color, codigo);
    if (_firebaseEnabled && _firebaseRepo != null) _firebaseRepo!.saveCodigoPorEmpresa(empresa, color, codigo).catchError((_) {});
  }
  @override Future<Map<String, String>> getAllCodigos() async => await _localRepo.getAllCodigos();
  @override Future<void> sync() async { if (_firebaseEnabled) await _localRepo.sync(); }
  @override Future<bool> hasPendingChanges() async => await _localRepo.hasPendingChanges();
  @override Future<void> clearAll() async { await _localRepo.clearAll(); }
}
