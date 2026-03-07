import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/services/firebase_service.dart';
import '../config/env.dart';

class RolloService extends FirebaseService {
  final String _collection = Env.col('rollos');

  Future<List<Rollo>> getAllRollos() async => await getAll<Rollo>(
    collectionPath: _collection,
    fromJson: Rollo.fromJson,
    orderBy: 'fechaCreacion',
    descending: true,
  );

  Future<void> createRollo(Rollo rollo) async => await create(
    collectionPath: _collection,
    id: rollo.id,
    data: rollo.toJson(),
  );

  Future<void> createRollos(List<Rollo> rollos) async {
    final batch = firestore.batch();
    for (final r in rollos) {
      batch.set(firestore.collection(_collection).doc(r.id), r.toJson());
    }
    await batch.commit();
  }

  Future<void> updateSucursal(
    String rolloId,
    String? nuevaSucursalId, { // Parámetro actualizado
    String? tipoMovimiento,
  }) async {
    final rollos = await getAllRollos();
    final rollo = rollos.firstWhere((r) => r.id == rolloId);
    final historial = rollo.historial ?? [];

    if (tipoMovimiento != null) {
      historial.add(
        HistorialMovimiento(
          tipo: tipoMovimiento,
          sucursalOrigenId: rollo.sucursalId ?? 'Sin sucursal',
          sucursalDestinoId: nuevaSucursalId ?? 'Sin sucursal',
          fecha: DateTime.now(),
        ),
      );
    }

    await update(
      collectionPath: _collection,
      id: rolloId,
      data: {
        'sucursalId': nuevaSucursalId, // Campo actualizado
        'historial': historial.map((e) => e.toJson()).toList(),
      },
    );
  }

  Future<void> deleteRollo(String id) async =>
      await delete(collectionPath: _collection, id: id);

  Future<void> updateMetraje(String rolloId, double metraje) async {
    await update(
      collectionPath: _collection,
      id: rolloId,
      data: {'metraje': metraje},
    );
  }
}
