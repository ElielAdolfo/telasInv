import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/ventas/carrito_item.dart';
import 'package:inv_telas/models/ventas/venta_rollo_seleccion.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import 'package:inv_telas/providers/carrito_state.dart';

class CarritoNotifier extends StateNotifier<CarritoState> {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CarritoNotifier(this._ref) : super(const CarritoState());

  CollectionReference<Map<String, dynamic>> get _carritoRef =>
      _db.collection(Env.col('carritos_activos'));

  void limpiar() {
    state = const CarritoState();
    _sincronizarCarritoConBaseDeDatos();
  }

  bool agregarMetrosEspecificoDeRollo({
    required StockActual rollo,
    required String nombreTela,
    required double mts,
    required double precio,
  }) {
    if (rollo.estado == StockRolloEstado.vendido) return false;
    if (rollo.metrajeActual < mts || mts <= 0) return false;

    final itemKey = 'especifico_${rollo.id}';

    List<VentaRolloSeleccion> sel = [
      VentaRolloSeleccion(
        rolloId: rollo.id,
        metrosExtraidos: mts,
        estadoAnterior: rollo.estado,
        estadoNuevo: rollo.metrajeActual == mts
            ? StockRolloEstado.vendido
            : StockRolloEstado.abierto,
      ),
    ];

    List<CarritoItem> items = List.from(state.items)
      ..removeWhere((i) => i.id == itemKey);

    items.add(
      CarritoItem(
        id: itemKey,
        tipoTelaId: rollo.tipoTelaId,
        colorId: rollo.colorId,
        loteId: rollo.loteId,
        cantidadMetros: mts,
        cantidadRollos: 0,
        precioUnitario: precio,
        esContinuo: true,
        rollosSeleccionados: sel,
      ),
    );

    state = state.copyWith(items: items);
    _sincronizarCarritoConBaseDeDatos();
    return true;
  }

  bool agregarRolloCompleto({
    required StockActual rollo,
    required String nombre,
    required double precio,
  }) {
    if (rollo.estado != StockRolloEstado.cerrado) return false;

    final itemKey = 'rollo_${rollo.id}';
    List<CarritoItem> items = List.from(state.items);

    if (items.any((i) => i.id == itemKey)) {
      return true;
    }

    items.add(
      CarritoItem(
        id: itemKey,
        tipoTelaId: rollo.tipoTelaId,
        colorId: rollo.colorId,
        loteId: rollo.loteId,
        cantidadMetros: 0,
        cantidadRollos: 1,
        precioUnitario: precio,
        esContinuo: true,
        rollosSeleccionados: [
          VentaRolloSeleccion(
            rolloId: rollo.id,
            metrosExtraidos: rollo.metrajeActual,
            estadoAnterior: StockRolloEstado.cerrado,
            estadoNuevo: StockRolloEstado.vendido,
          ),
        ],
      ),
    );

    state = state.copyWith(items: items);
    _sincronizarCarritoConBaseDeDatos();
    return true;
  }

  void eliminarItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
    _sincronizarCarritoConBaseDeDatos();
  }

  Future<void> _sincronizarCarritoConBaseDeDatos() async {
    state = state.copyWith(guardandoEnBaseDeDatos: true);

    try {
      String carritoDocumentId = "carrito_sucursal_actual";

      final Map<String, dynamic> datosCarrito = {
        'ultimaModificacion': FieldValue.serverTimestamp(),
        'items': state.items
            .map(
              (item) => {
                'id': item.id,
                'tipoTelaId': item.tipoTelaId,
                'colorId': item.colorId,
                'loteId': item.loteId,
                'cantidadMetros': item.cantidadMetros,
                'cantidadRollos': item.cantidadRollos,
                'precioUnitario': item.precioUnitario,
                'esContinuo': item.esContinuo,
                'rollosSeleccionados': item.rollosSeleccionados
                    .map((r) => r.toMap())
                    .toList(),
              },
            )
            .toList(),
      };

      await _carritoRef.doc(carritoDocumentId).set(datosCarrito);

      state = state.copyWith(
        guardandoEnBaseDeDatos: false,
        tieneErrorSincronizacion: false,
      );
    } catch (e) {
      print('Error al respaldar el carrito en segundo plano: $e');
      state = state.copyWith(
        guardandoEnBaseDeDatos: false,
        tieneErrorSincronizacion: true,
      );
    }
  }
}

final carritoVentasProvider =
    StateNotifierProvider<CarritoNotifier, CarritoState>(
      (ref) => CarritoNotifier(ref),
    );
