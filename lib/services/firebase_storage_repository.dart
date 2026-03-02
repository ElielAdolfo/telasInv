import '../models/models.dart';
import 'storage_repository.dart';

class FirebaseStorageRepository implements StorageRepository {
  FirebaseStorageRepository() { _init(); }
  Future<void> _init() async {}

  @override Future<List<RolloModel>> getAllRollos() async => [];
  @override Future<RolloModel?> getRolloById(String id) async => null;
  @override Future<void> saveRollo(RolloModel rollo) async {}
  @override Future<void> saveRollos(List<RolloModel> rollos) async {}
  @override Future<void> updateRollo(RolloModel rollo) async {}
  @override Future<void> deleteRollo(String id) async {}
  @override Future<void> deleteRollos(List<String> ids) async {}
  @override Future<List<EmpresaModel>> getAllEmpresas() async => [];
  @override Future<void> saveEmpresa(EmpresaModel empresa) async {}
  @override Future<void> updateEmpresa(EmpresaModel empresa) async {}
  @override Future<void> deleteEmpresa(String id) async {}
  @override Future<List<SucursalModel>> getAllSucursales() async => [];
  @override Future<void> saveSucursal(SucursalModel sucursal) async {}
  @override Future<void> updateSucursal(SucursalModel sucursal) async {}
  @override Future<void> deleteSucursal(String id) async {}
  @override Future<List<ColorTelaModel>> getAllColores() async => [];
  @override Future<void> saveColor(ColorTelaModel color) async {}
  @override Future<void> updateColor(ColorTelaModel color) async {}
  @override Future<void> deleteColor(String id) async {}
  @override Future<List<TipoTelaModel>> getAllTiposTela() async => [];
  @override Future<void> saveTipoTela(TipoTelaModel tipoTela) async {}
  @override Future<void> updateTipoTela(TipoTelaModel tipoTela) async {}
  @override Future<void> deleteTipoTela(String id) async {}
  @override Future<String?> getCodigoPorEmpresa(String empresa, String color) async => null;
  @override Future<void> saveCodigoPorEmpresa(String empresa, String color, String codigo) async {}
  @override Future<Map<String, String>> getAllCodigos() async => {};
  @override Future<void> sync() async {}
  @override Future<bool> hasPendingChanges() async => false;
  @override Future<void> clearAll() async {}
}
