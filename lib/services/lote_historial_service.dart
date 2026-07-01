// lib/services/lote_historial_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import '../config/env.dart';
import '../models/lotes/lote.dart';
import '../models/lotes/lote_estado.dart';
import '../models/lotes/lote_historial_estado.dart';

class LoteHistorialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _historialRef =>
      _db.collection(Env.col('loteHistorialEstado'));
  CollectionReference<Map<String, dynamic>> get _lotesRef =>
      _db.collection(Env.col('lotes'));
  CollectionReference<Map<String, dynamic>> get _detalleRef =>
      _db.collection(Env.col('loteDetalle'));
  CollectionReference<Map<String, dynamic>> get _stockRef =>
      _db.collection(Env.col('stock_actual'));

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
    List<StockActual> nuevosItemsStock = [];
    DateTime fechaActual = DateTime.now();

    // 2. Por cada detalle, recuperar sus rollos e integrarlos al JSON del Snapshot
    for (var detalleDoc in detallesSnapshot.docs) {
      final detalleData = detalleDoc.data();

      final rollosSnapshot = await _detalleRef
          .doc(detalleDoc.id)
          .collection('rollos')
          .orderBy('orden')
          .get();

      final rollosList = rollosSnapshot.docs.map((r) => r.data()).toList();
      detalleData['rollosSnapshot'] = rollosList;
      detallesConRollosList.add(detalleData);

      // =================================================================
      // GENERACIÓN DE STOCK ACTUAL (SOLO SI PASA A FINALIZADO)
      // =================================================================
      if (nuevoEstado == LoteEstado.finalizado) {
        for (var rolloMap in rollosList) {
          int cantidadRollosAgrupados = rolloMap['cantidad'] ?? 1;
          String idRollo = rolloMap['id'] ?? '';
          double metraje = (rolloMap['metraje'] ?? 0.0).toDouble();
          String colorId = rolloMap['colorId'] ?? '';
          String sucursalId = lote.sucursalId ?? '';
          Map<String, dynamic> atributos =
              rolloMap['atributosEspeciales'] != null
              ? Map<String, dynamic>.from(rolloMap['atributosEspeciales'])
              : {};

          // Si la cantidad agrupada es por ejemplo 10 (caso stock_007), creamos 10 registros
          for (int i = 1; i <= cantidadRollosAgrupados; i++) {
            final String nuevoStockId = _stockRef.doc().id;

            nuevosItemsStock.add(
              StockActual(
                id: nuevoStockId,
                loteId: lote.id,
                loteDetalleId: detalleDoc.id,
                tipoTelaId: detalleData['tipoTelaId'] ?? '',
                idRollo: idRollo,
                numeroFisico: i, // Multi-índice físico solicitado (1, 2, 3...)
                sucursalActualId: sucursalId,
                colorId: colorId.isEmpty ? null : colorId,
                atributosEspeciales: atributos,
                metrajeOriginal: metraje,
                metrajeActual: metraje,
                estado: StockRolloEstado
                    .cerrado, // Estado por defecto en almacén físico
                fechaIngresoStock: fechaActual,
              ),
            );
          }
        }
      }
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
      fechaCreacion: fechaActual,
      loteId: lote.id,
      estadoAnterior: lote.estado,
      estadoNuevo: nuevoEstado,
      observacion: observacion,
      snapshot: snapshotCompleto,
    );

    // 5. Inyectar operaciones ordenadas al Batch
    batch.set(_historialRef.doc(nuevoHistorialId), historial.toMap());

    // Actualizar estado e información de control en el lote principal
    Map<String, dynamic> updateLoteData = {
      'estado': nuevoEstado.nombre,
      'usuarioModificacion': usuarioId,
      'fechaModificacion': FieldValue.serverTimestamp(),
    };

    if (nuevoEstado == LoteEstado.finalizado) {
      updateLoteData['stockGenerado'] = true;
    }

    batch.update(_lotesRef.doc(lote.id), updateLoteData);

    // Escribir los elementos de stock si aplica
    for (var stockItem in nuevosItemsStock) {
      batch.set(_stockRef.doc(stockItem.id), stockItem.toMap());
    }

    // Ejecución atómica y segura
    await batch.commit();
  }
}
