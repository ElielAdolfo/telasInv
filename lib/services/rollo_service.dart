import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/services/firebase_service.dart';

class RolloService extends FirebaseService {
  static const String _collection = 'rollos';
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
    String? nuevaSucursal, {
    String? tipoMovimiento,
  }) async {
    final rollos = await getAllRollos();
    final rollo = rollos.firstWhere((r) => r.id == rolloId);
    final historial = rollo.historial ?? [];
    if (tipoMovimiento != null) {
      historial.add(
        HistorialMovimiento(
          tipo: tipoMovimiento,
          sucursalOrigen: rollo.sucursal ?? 'Sin sucursal',
          sucursalDestino: nuevaSucursal ?? 'Sin sucursal',
          fecha: DateTime.now(),
        ),
      );
    }
    await update(
      collectionPath: _collection,
      id: rolloId,
      data: {
        'sucursal': nuevaSucursal,
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
