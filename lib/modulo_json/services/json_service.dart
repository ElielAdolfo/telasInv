import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/json_collection.dart';

class JsonService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Colecciones disponibles
  final List<String> collections = [
    'codigoTelaProveedor',
    'codigoUnicoTelaProveedor',
    'colores',
    'empresas',
    'lotes',
    'loteDetalle', // <--- Esta es la que buscaremos para sus subcolecciones
    'menus',
    'monedas',
    'proveedores',
    'roles',
    'sucursales',
    'tiposTela',
    'usuarios',
    'stock_actual',
  ];

  /// Obtener colecciones separadas
  Future<List<JsonCollection>> getAllCollections() async {
    List<JsonCollection> result = [];

    for (final collection in collections) {
      try {
        final firebaseCollection = Env.col(collection);

        print('🔥 Leyendo colección: $firebaseCollection');

        final snapshot = await _db.collection(firebaseCollection).get();

        // Usamos Future.wait para manejar la asincronía si hay subcolecciones
        final data = await Future.wait(
          snapshot.docs.map((doc) async {
            final docData = {'id': doc.id, ..._convertFirestore(doc.data())};

            // Validamos de manera óptima si es loteDetalle para traer "rollos"
            if (collection == 'loteDetalle') {
              final subCollectionSnapshot = await doc.reference
                  .collection('rollos')
                  .get();

              docData['rollos'] = subCollectionSnapshot.docs
                  .map(
                    (subDoc) => {
                      'id': subDoc.id,
                      ..._convertFirestore(subDoc.data()),
                    },
                  )
                  .toList();
            }

            return docData;
          }).toList(),
        );

        result.add(JsonCollection(name: collection, data: data));

        print('✅ $collection: ${data.length} registros');
      } catch (e) {
        print('❌ Error colección $collection: $e');
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

        final data = await Future.wait(
          snapshot.docs.map((doc) async {
            final docData = {'id': doc.id, ..._convertFirestore(doc.data())};

            if (collection == 'loteDetalle') {
              final subCollectionSnapshot = await doc.reference
                  .collection('rollos')
                  .get();

              docData['rollos'] = subCollectionSnapshot.docs
                  .map(
                    (subDoc) => {
                      'id': subDoc.id,
                      ..._convertFirestore(subDoc.data()),
                    },
                  )
                  .toList();
            }

            return docData;
          }).toList(),
        );

        allData[collection] = data;
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
