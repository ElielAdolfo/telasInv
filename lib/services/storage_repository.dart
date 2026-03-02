import '../models/models.dart';

abstract class StorageRepository {
  // ROLLOS
  Future<List<RolloModel>> getAllRollos();
  Future<RolloModel?> getRolloById(String id);
  Future<void> saveRollo(RolloModel rollo);
  Future<void> saveRollos(List<RolloModel> rollos);
  Future<void> updateRollo(RolloModel rollo);
  Future<void> deleteRollo(String id);
  Future<void> deleteRollos(List<String> ids);

  // EMPRESAS
  Future<List<EmpresaModel>> getAllEmpresas();
  Future<void> saveEmpresa(EmpresaModel empresa);
  Future<void> updateEmpresa(EmpresaModel empresa);
  Future<void> deleteEmpresa(String id);

  // SUCURSALES
  Future<List<SucursalModel>> getAllSucursales();
  Future<void> saveSucursal(SucursalModel sucursal);
  Future<void> updateSucursal(SucursalModel sucursal);
  Future<void> deleteSucursal(String id);

  // COLORES
  Future<List<ColorTelaModel>> getAllColores();
  Future<void> saveColor(ColorTelaModel color);
  Future<void> updateColor(ColorTelaModel color);
  Future<void> deleteColor(String id);

  // TIPOS DE TELA
  Future<List<TipoTelaModel>> getAllTiposTela();
  Future<void> saveTipoTela(TipoTelaModel tipoTela);
  Future<void> updateTipoTela(TipoTelaModel tipoTela);
  Future<void> deleteTipoTela(String id);

  // CODIGOS
  Future<String?> getCodigoPorEmpresa(String empresa, String color);
  Future<void> saveCodigoPorEmpresa(String empresa, String color, String codigo);
  Future<Map<String, String>> getAllCodigos();

  // SINCRONIZACION
  Future<void> sync();
  Future<bool> hasPendingChanges();
  Future<void> clearAll();
}
