import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:inv_telas/models/lotes/codigo_tela_proveedor.dart';
import 'package:inv_telas/models/lotes/rollo_info.dart';
import 'package:inv_telas/services/lote_gastos_service.dart';
import 'package:inv_telas/models/lotes/lote_gasto_agrupado.dart';
import 'package:inv_telas/models/lotes/lote_detalle.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:inv_telas/services/moneda_service.dart';

class LoteGastosState {
  final bool cargando;
  final String? error;
  final List<LoteGastoAgrupado> agrupados;

  LoteGastosState({
    this.cargando = false,
    this.error,
    this.agrupados = const [],
  });

  LoteGastosState copyWith({
    bool? cargando,
    String? error,
    List<LoteGastoAgrupado>? agrupados,
  }) {
    return LoteGastosState(
      cargando: cargando ?? this.cargando,
      error: error,
      agrupados: agrupados ?? this.agrupados,
    );
  }
}

class LoteGastosNotifier extends StateNotifier<LoteGastosState> {
  final LoteGastosService _service = LoteGastosService();
  final MonedaService _monedaService = MonedaService();

  LoteGastosNotifier() : super(LoteGastosState());

  Future<void> cargarYAgruparConsola({
    required String empresaId,
    required String loteId,
  }) async {
    state = state.copyWith(cargando: true);

    try {
      final List<LoteDetalle> detalles = await _service.getByLote(loteId);
      developer.log(
        const JsonEncoder.withIndent('  ').convert(
          detalles.map((d) {
            final map = d.toMap();

            map.updateAll((key, value) {
              if (value is Timestamp) {
                return value.toDate().toIso8601String();
              }
              return value;
            });

            return map;
          }).toList(),
        ),
        name: 'debug.detalles',
      );

      if (detalles.isEmpty) {
        state = state.copyWith(cargando: false, agrupados: []);
        return;
      }

      final detalleIds = detalles
          .map((d) => d.id)
          .where((id) => id.isNotEmpty)
          .toList();

      final resultadoConsultas = await Future.wait([
        _service.getRollosPorDetalleIds(detalleIds),
        _service.getCodigosByIds(
          detalles
              .map((d) => d.codigoTelaProveedorId)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList(),
        ),
        _service.getTiposTelaByIds(
          detalles
              .map((d) => d.tipoTelaId)
              .whereType<String>()
              .where((id) => id.isNotEmpty)
              .toSet()
              .toList(),
        ),
      ]);

      final List<RolloInfo> todosLosRollos =
          resultadoConsultas[0] as List<RolloInfo>;

      final List<CodigoTelaProveedor> codigos =
          resultadoConsultas[1] as List<CodigoTelaProveedor>;

      final List<TipoTela> tiposTela = resultadoConsultas[2] as List<TipoTela>;

      final proveedorIds = codigos
          .map((c) => c.proveedorId)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final proveedores = await _service.getProveedoresByIds(proveedorIds);

      final monedaIds = detalles
          .map((d) => d.monedaId)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final monedas = await _monedaService.obtenerMonedasPorIds(monedaIds);

      final monedaMap = {for (final m in monedas) m.id: m};

      final codigoMap = {for (var c in codigos) c.id: c};
      final provMap = {for (var p in proveedores) p.id: p};

      final tipoMap = {for (var t in tiposTela) t.id: t};

      // Agrupar rollos por loteDetalleId
      final Map<String, List<RolloInfo>> rollosPorDetalleMap = {};

      for (final rollo in todosLosRollos) {
        rollosPorDetalleMap
            .putIfAbsent(rollo.loteDetalleId, () => [])
            .add(rollo);
      }

      final Map<String, Map<String, dynamic>> agrupado = {};

      for (final d in detalles) {
        final codigo = codigoMap[d.codigoTelaProveedorId];

        final provNombre = codigo != null
            ? (provMap[codigo.proveedorId]?.nombre ?? 'Sin Proveedor')
            : 'Sin Código';

        final tipoNombre = tipoMap[d.tipoTelaId]?.nombre ?? 'Sin Tipo Tela';

        final key = "${d.id}_${provNombre}_$tipoNombre";

        final rollosHijos = rollosPorDetalleMap[d.id] ?? [];

        // CORREGIDO
        final int totalCantidadRollos = rollosHijos.fold<int>(
          0,
          (sum, r) => sum + r.cantidad,
        );

        final double totalMetrajeReal = rollosHijos.fold<double>(
          0,
          (sum, r) => sum + (r.metraje * r.cantidad),
        );
        final moneda = monedaMap[d.monedaId];
        if (!agrupado.containsKey(key)) {
          agrupado[key] = {
            'loteDetalleId': d.id,
            'proveedor': provNombre,
            'tipoTela': tipoNombre,
            'cantidadRollos': 0,
            'totalMetros': 0.0,
            'monedaId': moneda?.id ?? '',
            'monedaNombre': moneda?.nombre ?? '',
            'monedaSimbolo': moneda?.simbolo ?? '',
            'costoMetroOrigen': d.costoMetroOrigen,
          };
        }

        agrupado[key]!['cantidadRollos'] += totalCantidadRollos;
        agrupado[key]!['totalMetros'] += totalMetrajeReal;
      }

      final List<LoteGastoAgrupado> resultado = agrupado.entries.map((e) {
        final data = e.value;

        return LoteGastoAgrupado(
          key: e.key,
          loteDetalleId: data['loteDetalleId'],
          proveedor: data['proveedor'],
          tipoTela: data['tipoTela'],
          cantidadRollos: data['cantidadRollos'],
          totalMetros: data['totalMetros'],
          monedaId: data['monedaId'],
          monedaNombre: data['monedaNombre'] ?? '',
          monedaSimbolo: data['monedaSimbolo'] ?? '',
          costoMetroOrigen: data['costoMetroOrigen'],
        );
      }).toList();

      final logDebug = resultado
          .map(
            (e) => {
              'key': e.key,
              'loteDetalleId': e.loteDetalleId,
              'proveedor': e.proveedor,
              'tipoTela': e.tipoTela,
              'cantidadRollos': e.cantidadRollos,
              'totalMetros': e.totalMetros,
              'monedaId': e.monedaId,
              'monedaNombre': e.monedaNombre,
              'monedaSimbolo': e.monedaSimbolo,
              'costoMetroOrigen': e.costoMetroOrigen,
            },
          )
          .toList();

      developer.log(
        "Lista 'resultado' generada con ÉXITO usando subcolecciones:",
        name: "lote.agrupado",
        error: const JsonEncoder.withIndent('  ').convert(logDebug),
      );

      state = state.copyWith(cargando: false, agrupados: resultado);
    } catch (e, stackTrace) {
      developer.log(
        "Error en cargarYAgruparConsola",
        error: e,
        stackTrace: stackTrace,
        name: "lote.agrupado",
      );

      state = state.copyWith(cargando: false, error: e.toString());
    }
  }
}

final loteGastosProvider =
    StateNotifierProvider<LoteGastosNotifier, LoteGastosState>(
      (ref) => LoteGastosNotifier(),
    );
