import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/json_collection.dart';

class JsonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Colecciones disponibles
  final List<String> collections = [
    'codigoTelaProveedor',
    'colores',
    'empresas',
    'lotes',
    'menus',
    'monedas',
    'proveedores',
    'roles',
    'sucursales',
    'tiposTela',
    'usuarios',
    'codigoUnicoTelaProveedor',
  ];

  /// Obtener colecciones separadas
  Future<List<JsonCollection>> getAllCollections() async {
    List<JsonCollection> result = [];

    for (final collection in collections) {
      try {
        /// AQUI ESTABA EL ERROR
        final firebaseCollection = Env.col(collection);

        print(
          '🔥 Leyendo colección: '
          '$firebaseCollection',
        );

        final snapshot = await _db.collection(firebaseCollection).get();

        final data = snapshot.docs
            .map((doc) => {'id': doc.id, ..._convertFirestore(doc.data())})
            .toList();

        result.add(JsonCollection(name: collection, data: data));

        print(
          '✅ $collection: '
          '${data.length} registros',
        );
      } catch (e) {
        print(
          '❌ Error colección '
          '$collection: $e',
        );
      }
    }

    return result;
  }

  /// Obtener TODO el JSON
  Future<Map<String, dynamic>> getAllJson() async {
    Map<String, dynamic> allData = {};

    for (final collection in collections) {
      try {
        final firebaseCollection = Env.col(collection);

        final snapshot = await _db.collection(firebaseCollection).get();

        allData[collection] = snapshot.docs
            .map((doc) => {'id': doc.id, ..._convertFirestore(doc.data())})
            .toList();
      } catch (e) {
        allData[collection] = {'error': e.toString()};
      }
    }

    return allData;
  }

  dynamic _convertFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    }

    if (value is Map) {
      return value.map((key, val) => MapEntry(key, _convertFirestore(val)));
    }

    if (value is List) {
      return value.map(_convertFirestore).toList();
    }

    return value;
  }
}
