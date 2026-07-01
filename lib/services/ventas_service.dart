// lib/services/ventas_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import '../config/env.dart';
import '../models/ventas/jornada_laboral.dart';
import '../models/ventas/venta.dart';

class VentasService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jornadasRef =>
      _db.collection(Env.col('jornadas_laborales'));
  CollectionReference<Map<String, dynamic>> get _ventasRef =>
      _db.collection(Env.col('ventas'));
  CollectionReference<Map<String, dynamic>> get _stockRef =>
      _db.collection(Env.col('stock_actual'));

  // =================================================================
  // OPERACIONES DE JORNADA
  // =================================================================
  Future<void> abrirJornada(JornadaLaboral jornada) async {
    await _jornadasRef.doc(jornada.id).set(jornada.toMap());
  }

  Future<void> cerrarJornada(String jornadaId, double cajaFinalBs) async {
    await _jornadasRef.doc(jornadaId).update({
      'cajaFinalBs': cajaFinalBs,
      'fechaCierre': FieldValue.serverTimestamp(),
      'abierta': false,
    });
  }

  Future<JornadaLaboral?> obtenerJornadaActiva(String sucursalId) async {
    final snap = await _jornadasRef
        .where('sucursalId', isEqualTo: sucursalId)
        .where('abierta', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return JornadaLaboral.fromMap(snap.docs.first.data());
  }

  // =================================================================
  // TRANSACCIÓN ATÓMICA DE VENTA (PUNTO CRÍTICO)
  // =================================================================
  Future<void> procesarVentaAtomica(Venta venta) async {
    await _db.runTransaction((transaction) async {
      // 1. Validar y descontar stock por cada item del carrito
      for (var detalle in venta.detalles) {
        final DocumentReference docRolloRef = _stockRef.doc(
          detalle.stockActualId,
        );
        final DocumentSnapshot docRolloSnap = await transaction.get(
          docRolloRef,
        );

        if (!docRolloSnap.exists) {
          throw Exception(
            "El rollo físico especificado ya no existe en el inventario.",
          );
        }

        final data = docRolloSnap.data() as Map<String, dynamic>;
        double metrajeActual = (data['metrajeActual'] ?? 0.0).toDouble();
        String estadoActual = data['estado'] ?? 'CERRADO';

        if (estadoActual == 'VENDIDO') {
          throw Exception(
            "Uno de los rollos seleccionados ya fue vendido por otro cajero.",
          );
        }

        if (detalle.esVentaPorRolloEntero) {
          // Venta de rollo completo
          transaction.update(docRolloRef, {
            'metrajeActual': 0.0,
            'estado': StockRolloEstado.vendido.nombre,
          });
        } else {
          // Venta parcial (Metreado)
          if (metrajeActual < detalle.metrajeVendido) {
            throw Exception(
              "Metraje insuficiente en el rollo físico seleccionado.",
            );
          }

          double nuevoMetraje = metrajeActual - detalle.metrajeVendido;
          // Si el residuo es insignificante (menos de 10 cm), se da por liquidado/vendido
          String nuevoEstado = nuevoMetraje <= 0.1
              ? StockRolloEstado.vendido.nombre
              : StockRolloEstado.abierto.nombre;

          transaction.update(docRolloRef, {
            'metrajeActual': nuevoMetraje <= 0.1 ? 0.0 : nuevoMetraje,
            'estado': nuevoEstado,
          });
        }
      }

      // 2. Registrar la cabecera de la venta
      final DocumentReference nuevaVentaRef = _ventasRef.doc(venta.id);
      transaction.set(nuevaVentaRef, venta.toMap());

      // 3. Registrar los subdocumentos del detalle de la venta
      for (var detalle in venta.detalles) {
        final DocumentReference nuevoDetalleRef = nuevaVentaRef
            .collection('detalles')
            .doc();
        transaction.set(nuevoDetalleRef, detalle.toMap());
      }
    });
  }
}
