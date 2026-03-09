import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lote.dart';
import 'firebase_service.dart';
import '../config/env.dart';

class LoteService extends FirebaseService {
  final String _collection = Env.col('lotes');

  Future<List<Lote>> getLotes() async => await getAll<Lote>(
    collectionPath: _collection,
    fromJson: Lote.fromJson,
    orderBy: 'fecha',
    descending: true,
  );

  Future<void> addLote(Lote lote) async => await create(
    collectionPath: _collection,
    id: lote.id,
    data: lote.toJson(),
  );

  Future<void> updateLote(Lote lote) async => await update(
    collectionPath: _collection,
    id: lote.id,
    data: lote.toJson(),
  );
}
