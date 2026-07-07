import 'package:inv_telas/models/ventas/venta_rollo_seleccion.dart';

import '../../models/ventas/stock_actual.dart';

class VentaStockSelector {
  static List<StockActual> obtenerRolloAbierto(
    List<StockActual> stock,
    String tipoId,
    String? colId,
    String lote,
  ) {
    return stock
        .where(
          (s) =>
              s.tipoTelaId == tipoId &&
              s.colorId == colId &&
              s.loteId == lote &&
              s.estado == StockRolloEstado.abierto,
        )
        .toList();
  }

  static List<StockActual> buscarRollosCerrados(
    List<StockActual> stock,
    String tipoId,
    String? colId,
    String lote,
  ) {
    return stock
        .where(
          (s) =>
              s.tipoTelaId == tipoId &&
              s.colorId == colId &&
              s.loteId == lote &&
              s.estado == StockRolloEstado.cerrado,
        )
        .toList();
  }

  static List<StockActual> obtenerSobras(
    List<StockActual> stock,
    String tipoId,
    String? colId,
    String lote,
  ) {
    return stock
        .where(
          (s) =>
              s.tipoTelaId == tipoId &&
              s.colorId == colId &&
              s.loteId == lote &&
              s.estado == StockRolloEstado.sobra,
        )
        .toList();
  }

  static bool validarStockVenta(
    List<StockActual> stock,
    String tipoId,
    String? colId,
    String lote,
    double req,
    bool esCont,
  ) {
    if (esCont) {
      return stock.any(
        (s) =>
            s.tipoTelaId == tipoId &&
            s.colorId == colId &&
            s.loteId == lote &&
            s.estado != StockRolloEstado.vendido &&
            s.metrajeActual >= req,
      );
    }
    double total = stock
        .where(
          (s) =>
              s.tipoTelaId == tipoId &&
              s.colorId == colId &&
              s.loteId == lote &&
              s.estado != StockRolloEstado.vendido,
        )
        .fold(0.0, (sum, s) => sum + s.metrajeActual);
    return total >= req;
  }

  static List<VentaRolloSeleccion> resolverVentaMetros({
    required List<StockActual> stockCompleto,
    required String tipoTelaId,
    required String? colorId,
    required String loteId,
    required double metrosRequeridos,
  }) {
    List<VentaRolloSeleccion> selecciones = [];
    double remanente = metrosRequeridos;

    // Prioridad 1: Abiertos
    var abiertos = obtenerRolloAbierto(
      stockCompleto,
      tipoTelaId,
      colorId,
      loteId,
    );
    for (var r in abiertos) {
      if (remanente <= 0) break;
      double ext = r.metrajeActual >= remanente ? remanente : r.metrajeActual;
      remanente -= ext;
      selecciones.add(
        VentaRolloSeleccion(
          rolloId: r.id,
          metrosExtraidos: ext,
          estadoAnterior: StockRolloEstado.abierto,
          estadoNuevo: r.metrajeActual == ext
              ? StockRolloEstado.vendido
              : StockRolloEstado.abierto,
        ),
      );
    }

    // Prioridad 2: Cerrados
    if (remanente > 0) {
      var cerrados = buscarRollosCerrados(
        stockCompleto,
        tipoTelaId,
        colorId,
        loteId,
      );
      for (var r in cerrados) {
        if (remanente <= 0) break;
        double ext = r.metrajeActual >= remanente ? remanente : r.metrajeActual;
        remanente -= ext;
        selecciones.add(
          VentaRolloSeleccion(
            rolloId: r.id,
            metrosExtraidos: ext,
            estadoAnterior: StockRolloEstado.cerrado,
            estadoNuevo: r.metrajeActual == ext
                ? StockRolloEstado.vendido
                : StockRolloEstado.abierto,
          ),
        );
      }
    }

    // Prioridad 3: Sobras (Retazos)
    if (remanente > 0) {
      var sobras = obtenerSobras(stockCompleto, tipoTelaId, colorId, loteId);
      for (var r in sobras) {
        if (remanente <= 0) break;
        double ext = r.metrajeActual >= remanente ? remanente : r.metrajeActual;
        remanente -= ext;
        selecciones.add(
          VentaRolloSeleccion(
            rolloId: r.id,
            metrosExtraidos: ext,
            estadoAnterior: StockRolloEstado.sobra,
            estadoNuevo: r.metrajeActual == ext
                ? StockRolloEstado.vendido
                : StockRolloEstado.sobra,
          ),
        );
      }
    }
    return selecciones;
  }

  static List<VentaRolloSeleccion> resolverVentaContinua({
    required List<StockActual> stockCompleto,
    required String tipoTelaId,
    required String? colorId,
    required String loteId,
    required double metrosRequeridos,
  }) {
    var validos = stockCompleto
        .where(
          (s) =>
              s.tipoTelaId == tipoTelaId &&
              s.colorId == colorId &&
              s.loteId == loteId &&
              s.estado != StockRolloEstado.vendido &&
              s.metrajeActual >= metrosRequeridos,
        )
        .toList();
    if (validos.isEmpty) return [];

    validos.sort((a, b) {
      int valA = a.estado == StockRolloEstado.abierto
          ? 0
          : (a.estado == StockRolloEstado.cerrado ? 1 : 2);
      int valB = b.estado == StockRolloEstado.abierto
          ? 0
          : (b.estado == StockRolloEstado.cerrado ? 1 : 2);
      return valA.compareTo(valB);
    });

    var elegido = validos.first;
    return [
      VentaRolloSeleccion(
        rolloId: elegido.id,
        metrosExtraidos: metrosRequeridos,
        estadoAnterior: elegido.estado,
        estadoNuevo: elegido.metrajeActual == metrosRequeridos
            ? StockRolloEstado.vendido
            : StockRolloEstado.abierto,
      ),
    ];
  }
}
