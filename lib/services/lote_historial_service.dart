import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/lotes/lote.dart'; // Asegúrate de importar tu modelo Lote
import 'package:inv_telas/models/lotes/lote_estado.dart';
import 'package:inv_telas/models/lotes/lote_historial_estado.dart';
import '../config/env.dart';

class LoteHistorialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _historialRef =>
      _db.collection(Env.col('loteHistorialEstado'));

  CollectionReference<Map<String, dynamic>> get _lotesRef =>
      _db.collection(Env.col('lotes'));

  CollectionReference<Map<String, dynamic>> get _detalleRef =>
      _db.collection(Env.col('loteDetalle'));

  /// Registra el cambio de estado y genera el Snapshot completo (Lote + Detalles + Rollos)
  Future<void> registrarCambioEstado({
    required Lote lote,
    required LoteEstado nuevoEstado,
    required String usuarioId,
    String? observacion,
  }) async {
    final WriteBatch batch = _db.batch();

    // 1. Obtener todos los detalles activos de este lote
    final detallesSnapshot = await _detalleRef
        .where('loteId', isEqualTo: lote.id)
        .where('eliminado', isEqualTo: false)
        .get();

    List<Map<String, dynamic>> detallesConRollosList = [];

    // 2. Por cada detalle, recuperar sus rollos e integrarlos al JSON del Snapshot
    for (var detalleDoc in detallesSnapshot.docs) {
      final detalleData = detalleDoc.data();

      final rollosSnapshot = await _detalleRef
          .doc(detalleDoc.id)
          .collection('rollos')
          .orderBy('orden')
          .get();

      final rollosList = rollosSnapshot.docs.map((r) => r.data()).toList();

      // Adjuntamos los rollos dentro de la estructura del detalle
      detalleData['rollosSnapshot'] = rollosList;
      detallesConRollosList.add(detalleData);
    }

    // 3. Crear el mapa completo de captura (Snapshot)
    final Map<String, dynamic> snapshotCompleto = {
      'lote': lote.toMap(),
      'detalles': detallesConRollosList,
    };

    // 4. Preparar el documento de Historial
    final nuevoHistorialId = _historialRef.doc().id;
    final historial = LoteHistorialEstado(
      id: nuevoHistorialId,
      activo: true,
      eliminado: false,
      usuarioCreacion: usuarioId,
      fechaCreacion: DateTime.now(),
      loteId: lote.id,
      estadoAnterior: lote
          .estado, // Asumiendo que tu modelo Lote tiene la propiedad 'estado'
      estadoNuevo: nuevoEstado,
      observacion: observacion,
      snapshot: snapshotCompleto,
    );

    // 5. Agregar operaciones al Batch
    // - Insertar historial
    batch.set(_historialRef.doc(nuevoHistorialId), historial.toMap());

    // - Actualizar estado e información de control en el lote principal
    batch.update(_lotesRef.doc(lote.id), {
      'estado': nuevoEstado.nombre,
      'usuarioModificacion': usuarioId,
      'fechaModificacion': FieldValue.serverTimestamp(),
    });

    // Ejecución atómica
    await batch.commit();
  }
}
