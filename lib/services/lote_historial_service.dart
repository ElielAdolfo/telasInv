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

    // ====================================================================================
    // PRE-PROCESAMIENTO MATEMÁTICO DE PRORRATEO (SOLO SI PASA A FINALIZADO)
    // ====================================================================================
    Map<String, List<Map<String, dynamic>>> rollosCachadosPorDetalle = {};
    double metrosTotalesDelLoteCompleto = 0.0;
    Map<String, double> metrosTotalesPorDetalleId = {};

    // Primero leemos los rollos de la base de datos para mapear el metraje real exacto del lote entero
    for (var detalleDoc in detallesSnapshot.docs) {
      final rollosSnapshot = await _detalleRef
          .doc(detalleDoc.id)
          .collection('rollos')
          .orderBy('orden')
          .get();

      final rollosList = rollosSnapshot.docs.map((r) => r.data()).toList();
      rollosCachadosPorDetalle[detalleDoc.id] = rollosList;

      double metrosDeEsteDetalle = 0.0;
      for (var rMap in rollosList) {
        int cant = rMap['cantidad'] ?? 1;
        double m = (rMap['metraje'] ?? 0.0).toDouble();
        metrosDeEsteDetalle += (m * cant);
      }

      metrosTotalesPorDetalleId[detalleDoc.id] = metrosDeEsteDetalle;
      metrosTotalesDelLoteCompleto += metrosDeEsteDetalle;
    }

    // Traemos todos los gastos activos cargados para este lote
    double totalGastosComunesLote = 0.0;
    Map<String, double> totalGastosEnlazadosPorDetalleId = {};

    if (nuevoEstado == LoteEstado.finalizado) {
      final gastosSnapshot = await _db
          .collection(Env.col('gastos'))
          .where('loteId', isEqualTo: lote.id)
          .where('eliminado', isEqualTo: false)
          .get();

      for (var gastoDoc in gastosSnapshot.docs) {
        final gData = gastoDoc.data();
        double totalBs = (gData['totalBs'] ?? 0.0).toDouble();
        String? linkedDetalleId = gData['loteDetalleId'];

        if (linkedDetalleId == null || linkedDetalleId.isEmpty) {
          // Gasto común total (Pasajes, comida, etc.)
          totalGastosComunesLote += totalBs;
        } else {
          // Gasto específico enlazado a una tela (Transporte de tela x)
          totalGastosEnlazadosPorDetalleId[linkedDetalleId] =
              (totalGastosEnlazadosPorDetalleId[linkedDetalleId] ?? 0.0) +
              totalBs;
        }
      }
    }
    // ====================================================================================

    // 2. Construcción de registros y snapshots
    for (var detalleDoc in detallesSnapshot.docs) {
      final detalleData = detalleDoc.data();
      final rollosList = rollosCachadosPorDetalle[detalleDoc.id] ?? [];

      detalleData['rollosSnapshot'] = rollosList;
      detallesConRollosList.add(detalleData);

      if (nuevoEstado == LoteEstado.finalizado) {
        double costoMetroOrigen = (detalleData['costoMetroOrigen'] ?? 0.0)
            .toDouble();

        // Factores unitarios por metro para este loteDetalle
        double metrosDeEsteDetalle =
            metrosTotalesPorDetalleId[detalleDoc.id] ?? 0.0;
        double gastoEnlazadoPorMetro = metrosDeEsteDetalle > 0
            ? (totalGastosEnlazadosPorDetalleId[detalleDoc.id] ?? 0.0) /
                  metrosDeEsteDetalle
            : 0.0;

        double gastoComunPorMetro = metrosTotalesDelLoteCompleto > 0
            ? totalGastosComunesLote / metrosTotalesDelLoteCompleto
            : 0.0;

        for (var rolloMap in rollosList) {
          int cantidadRollosAgrupados = rolloMap['cantidad'] ?? 1;
          String idRollo = rolloMap['id'] ?? '';
          double metrajeRolloReal = (rolloMap['metraje'] ?? 0.0).toDouble();
          String colorId = rolloMap['colorId'] ?? '';
          String sucursalId = lote.sucursalId ?? '';
          Map<String, dynamic> atributos =
              rolloMap['atributosEspeciales'] != null
              ? Map<String, dynamic>.from(rolloMap['atributosEspeciales'])
              : {};

          // Cálculo individual por rollo respetando variaciones de metraje arbitrarias
          double individualGastoComun = metrajeRolloReal * gastoComunPorMetro;
          double individualGastoEnlazado =
              metrajeRolloReal * gastoEnlazadoPorMetro;
          double individualPrecioCompra = metrajeRolloReal * costoMetroOrigen;
          double individualPrecioTotal =
              individualPrecioCompra +
              individualGastoComun +
              individualGastoEnlazado;

          for (int i = 1; i <= cantidadRollosAgrupados; i++) {
            final String nuevoStockId = _stockRef.doc().id;

            nuevosItemsStock.add(
              StockActual(
                id: nuevoStockId,
                loteId: lote.id,
                loteDetalleId: detalleDoc.id,
                tipoTelaId: detalleData['tipoTelaId'] ?? '',
                idRollo: idRollo,
                numeroFisico: i,
                sucursalActualId: sucursalId,
                colorId: colorId.isEmpty ? null : colorId,
                atributosEspeciales: atributos,
                metrajeOriginal: metrajeRolloReal,
                metrajeActual: metrajeRolloReal,
                estado: StockRolloEstado.cerrado,
                fechaIngresoStock: fechaActual,
                // INYECCIÓN ASIGNADA CON ÉXITO
                gastosComunes: individualGastoComun,
                gastosEnlazado: individualGastoEnlazado,
                precioCompraRollo: individualPrecioCompra,
                precioTotal: individualPrecioTotal,
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

    // Escribir los elementos de stock calculados al céntimo
    for (var stockItem in nuevosItemsStock) {
      batch.set(_stockRef.doc(stockItem.id), stockItem.toMap());
    }

    // Ejecución atómica y segura
    await batch.commit();
  }
}
