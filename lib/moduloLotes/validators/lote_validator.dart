import 'package:inv_telas/models/lotes/lote.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/lotes/lote_estado.dart';
import 'package:inv_telas/models/lotes/lote_gasto.dart';

class LoteValidator {
  // ==========================================================
  // VALIDACIÓN GENERAL
  // ==========================================================

  static List<String> validar({
    required Lote lote,
    required List<LoteDetalle> detalles,
    List<LoteGasto> gastos = const [],
  }) {
    final errores = <String>[];

    _validarCabecera(lote, errores);

    _validarDetalles(detalles, errores);

    _validarGastos(gastos, errores);

    _validarEstado(lote, detalles, gastos, errores);

    return errores;
  }

  static void validarOError({
    required Lote lote,
    required List<LoteDetalle> detalles,
    List<LoteGasto> gastos = const [],
  }) {
    final errores = validar(lote: lote, detalles: detalles, gastos: gastos);

    if (errores.isNotEmpty) {
      throw Exception(errores.join('\n'));
    }
  }

  // ==========================================================
  // CABECERA
  // ==========================================================

  static void _validarCabecera(Lote lote, List<String> errores) {
    if (lote.empresaId.trim().isEmpty) {
      errores.add('La empresa es obligatoria.');
    }

    if (lote.monedaId.trim().isEmpty) {
      errores.add('La moneda es obligatoria.');
    }

    if (lote.numeroLote.trim().isEmpty) {
      errores.add('El número de lote es obligatorio.');
    }
  }

  // ==========================================================
  // DETALLES
  // ==========================================================

  static void _validarDetalles(
    List<LoteDetalle> detalles,
    List<String> errores,
  ) {
    if (detalles.isEmpty) {
      errores.add('Debe existir al menos un detalle.');
      return;
    }

    for (final detalle in detalles) {
      if (detalle.tipoTelaId.trim().isEmpty) {
        errores.add('Existe un detalle sin tipo de tela.');
      }

      if (detalle.cantidadRollos <= 0) {
        errores.add('La cantidad de rollos debe ser mayor a cero.');
      }

      if (detalle.metrosPorRollo <= 0) {
        errores.add('Los metros por rollo deben ser mayores a cero.');
      }

      if (detalle.totalMetros <= 0) {
        errores.add('El total de metros debe ser mayor a cero.');
      }

      if (detalle.costoMetroOrigen < 0) {
        errores.add('El costo por metro origen no puede ser negativo.');
      }

      if (detalle.costoMetroBase < 0) {
        errores.add('El costo por metro base no puede ser negativo.');
      }
    }
  }

  // ==========================================================
  // GASTOS
  // ==========================================================

  static void _validarGastos(List<LoteGasto> gastos, List<String> errores) {
    for (final gasto in gastos) {
      if (gasto.descripcion.trim().isEmpty) {
        errores.add('Existe un gasto sin descripción.');
      }

      if (gasto.monedaId.trim().isEmpty) {
        errores.add('Existe un gasto sin moneda.');
      }

      if (gasto.monto <= 0) {
        errores.add('Todos los gastos deben ser mayores a cero.');
      }

      if (gasto.tipoCambio <= 0) {
        errores.add('El tipo de cambio del gasto debe ser mayor a cero.');
      }
    }
  }

  // ==========================================================
  // ESTADOS
  // ==========================================================

  static void _validarEstado(
    Lote lote,
    List<LoteDetalle> detalles,
    List<LoteGasto> gastos,
    List<String> errores,
  ) {
    switch (lote.estado) {
      case LoteEstado.borrador:
        break;

      case LoteEstado.enTransito:
        if (detalles.isEmpty) {
          errores.add('No puede enviarse a tránsito sin detalles.');
        }
        break;

      case LoteEstado.revision:
        if (detalles.isEmpty) {
          errores.add('No puede pasar a revisión sin detalles.');
        }
        break;

      case LoteEstado.finalizado:
        _validarFinalizacion(lote, detalles, gastos, errores);
        break;

      case LoteEstado.cancelado:
        break;
    }
  }

  // ==========================================================
  // FINALIZACIÓN
  // ==========================================================

  static void _validarFinalizacion(
    Lote lote,
    List<LoteDetalle> detalles,
    List<LoteGasto> gastos,
    List<String> errores,
  ) {
    if (detalles.isEmpty) {
      errores.add('No puede finalizar un lote sin detalles.');
    }
  }

  // ==========================================================
  // CAMBIOS DE ESTADO
  // ==========================================================

  static bool puedeCambiarEstado({
    required LoteEstado actual,
    required LoteEstado nuevo,
  }) {
    switch (actual) {
      case LoteEstado.borrador:
        return nuevo == LoteEstado.enTransito || nuevo == LoteEstado.cancelado;

      case LoteEstado.enTransito:
        return nuevo == LoteEstado.revision || nuevo == LoteEstado.cancelado;

      case LoteEstado.revision:
        return nuevo == LoteEstado.finalizado || nuevo == LoteEstado.cancelado;

      case LoteEstado.finalizado:
        return false;

      case LoteEstado.cancelado:
        return false;
    }
  }
}
