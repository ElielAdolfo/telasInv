// lib/services/registro_diario_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/ventas/registro_diario.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';

class RegistroDiarioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> procesarVentaTransaccional({
    required RegistroDiario venta,
  }) async {
    final CollectionReference registroRef = _db.collection(
      Env.col('registroDiario'),
    );
    final CollectionReference stockRef = _db.collection(
      Env.col('stock_actual'),
    );

    // Ejecutamos una transacción atómica de Firestore
    await _db.runTransaction((transaction) async {
      // 1. Verificar y preparar las actualizaciones de Inventario primero (Lecturas obligatorias)
      List<Map<String, dynamic>> actualizacionesStock = [];

      for (var item in venta.itemsVendidos) {
        for (var rolloSel in item.rollosSeleccionados) {
          final DocumentReference docRolloRef = stockRef.doc(rolloSel.rolloId);

          // Leer el estado actual directo desde la transacción
          final docSnapshot = await transaction.get(docRolloRef);
          if (!docSnapshot.exists) {
            throw Exception(
              "El rollo con ID ${rolloSel.rolloId} no existe en el inventario.",
            );
          }

          final stockActual = StockActual.fromJson(
            docSnapshot.data() as Map<String, dynamic>,
          );

          // Calcular nueva cantidad física en stock
          double nuevoMetraje =
              stockActual.metrajeActual - rolloSel.metrosExtraidos;
          if (nuevoMetraje < 0) {
            throw Exception(
              "Inventario insuficiente para la tela: ${item.tipoTelaId}",
            );
          }

          // Lógica de transiciones automática:
          StockRolloEstado nuevoEstado = rolloSel.estadoNuevo;

          // Regula dinámicamente si pasa de cerrado a abierto
          if (nuevoMetraje == 0) {
            nuevoEstado = StockRolloEstado.vendido;
          } else if (stockActual.estado == StockRolloEstado.cerrado &&
              rolloSel.metrosExtraidos > 0) {
            nuevoEstado = StockRolloEstado.abierto;
          }

          actualizacionesStock.add({
            'reference': docRolloRef,
            'data': {
              'metrajeActual': nuevoMetraje,
              'estado':
                  nuevoEstado.nombre, // Guarda el string 'ABIERTO' o 'VENDIDO'
            },
          });
        }
      }

      // 2. Aplicar escrituras en el Stock
      for (var cambio in actualizacionesStock) {
        transaction.update(
          cambio['reference'] as DocumentReference,
          cambio['data'] as Map<String, dynamic>,
        );
      }

      // 3. Crear el documento de la Venta en Registro Diario
      final DocumentReference nuevaVentaRef = registroRef.doc();
      transaction.set(nuevaVentaRef, venta.toMap());
    });
  }
}
