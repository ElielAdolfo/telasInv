import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/models.dart';
import 'firebase_service.dart';
import '../config/env.dart';

class CatalogService extends FirebaseService {
  final String _empresasCol = Env.col('catalog_empresas');
  final String _sucursalesCol = Env.col('catalog_sucursales');
  final String _coloresCol = Env.col('catalog_colores');
  final String _tiposCol = Env.col('catalog_tipos_tela');
  final String _anchosCol = Env.col('catalog_anchos');

  // EMPRESAS
  Future<List<Empresa>> getEmpresas() async => await getAll<Empresa>(
    collectionPath: _empresasCol,
    fromJson: Empresa.fromJson,
    orderBy: 'nombre',
  );

  Future<void> addEmpresa(Empresa empresa) async => await create(
    collectionPath: _empresasCol,
    id: empresa.id,
    data: empresa.toJson(),
  );

  // SUCURSALES
  Future<List<Sucursal>> getSucursales() async => await getAll<Sucursal>(
    collectionPath: _sucursalesCol,
    fromJson: Sucursal.fromJson,
    orderBy: 'nombre',
  );

  Future<void> addSucursal(Sucursal sucursal) async => await create(
    collectionPath: _sucursalesCol,
    id: sucursal.id,
    data: sucursal.toJson(),
  );

  // COLORES
  Future<List<ColorTela>> getColores() async => await getAll<ColorTela>(
    collectionPath: _coloresCol,
    fromJson: ColorTela.fromJson,
    orderBy: 'nombre',
  );

  Future<void> addColor(ColorTela color) async => await create(
    collectionPath: _coloresCol,
    id: color.id,
    data: color.toJson(),
  );

  // TIPOS DE TELA
  Future<List<TipoTela>> getTiposTela() async => await getAll<TipoTela>(
    collectionPath: _tiposCol,
    fromJson: TipoTela.fromJson,
    orderBy: 'nombre',
  );

  Future<void> addTipoTela(TipoTela tipo) async =>
      await create(collectionPath: _tiposCol, id: tipo.id, data: tipo.toJson());

  Future<List<Ancho>> getAnchos() async => await getAll<Ancho>(
    collectionPath: _anchosCol,
    fromJson: Ancho.fromJson,
    orderBy: 'nombre',
  );

  Future<void> addAncho(Ancho ancho) async => await create(
    collectionPath: _anchosCol,
    id: ancho.id,
    data: ancho.toJson(),
  );
}
