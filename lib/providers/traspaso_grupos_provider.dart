import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/color_tela.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import 'traspaso_provider.dart';
import 'color_provider.dart';
import 'tipo_tela_provider.dart';
import 'codigo_unico_tela_proveedor_provider.dart';

/// Modelo de vista optimizado que agrupa los rollos listos para renderizar
class TraspasoGrupoUi {
  final String groupKey;
  final String tipoTelaNombre;
  final String colorNombre;
  final Color flutterColor;
  final String? codigoUnicoProveedor;
  final List<StockActual> rollos;

  /// Mapa ID_CAMPO -> NOMBRE_CAMPO
  final Map<String, String> nombresCamposConfigurables;

  /// Atributos diferenciadores específicos de este grupo que deben ir en la cabecera
  final Map<String, String> valoresDiferenciadoresGrupo;

  TraspasoGrupoUi({
    required this.groupKey,
    required this.tipoTelaNombre,
    required this.colorNombre,
    required this.flutterColor,
    this.codigoUnicoProveedor,
    required this.rollos,
    required this.nombresCamposConfigurables,
    this.valoresDiferenciadoresGrupo = const {},
  });
}

/// Provider que procesa y cruza los catálogos en memoria sin generar lecturas extras a Firebase
final traspasoGruposProcesadosProvider =
    Provider.family<AsyncValue<List<TraspasoGrupoUi>>, String>((
      ref,
      empresaId,
    ) {
      print('🔥 traspasoGruposProcesadosProvider EJECUTÁNDOSE');

      final state = ref.watch(traspasoProvider);
      final coloresAsync = ref.watch(coloresProvider(empresaId));
      final tiposTelaAsync = ref.watch(tiposTelaProvider(empresaId));
      final codigosAsync = ref.watch(
        codigosUnicoTelaProveedorProvider(empresaId),
      );

      if (state.isLoading ||
          coloresAsync.isLoading ||
          tiposTelaAsync.isLoading ||
          codigosAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (coloresAsync.hasError) {
        return AsyncValue.error(coloresAsync.error!, coloresAsync.stackTrace!);
      }

      if (tiposTelaAsync.hasError) {
        return AsyncValue.error(
          tiposTelaAsync.error!,
          tiposTelaAsync.stackTrace!,
        );
      }

      if (codigosAsync.hasError) {
        return AsyncValue.error(codigosAsync.error!, codigosAsync.stackTrace!);
      }

      final rollosCerrados = state.items
          .where((item) => item.estado == StockRolloEstado.cerrado)
          .toList();

      print('');
      print('================ STOCK RECIBIDO =================');

      for (final r in rollosCerrados) {
        print('');
        print('ROLLO: ${r.id}');
        print('TIPO TELA: ${r.tipoTelaId}');
        print('COLOR: ${r.colorId}');
        print('NUMERO: ${r.numeroFisico}');
        print('METRAJE: ${r.metrajeActual}');
        print('ATRIBUTOS:');

        if (r.atributosEspeciales == null || r.atributosEspeciales.isEmpty) {
          print('VACIO');
        } else {
          r.atributosEspeciales.forEach((k, v) {
            print('$k => $v');
          });
        }
      }

      print('=================================================');
      print('');

      final listaColores = coloresAsync.value ?? [];
      final listaTiposTela = tiposTelaAsync.value ?? [];
      final listaCodigosUnicos = codigosAsync.value ?? [];

      /// =====================================================
      /// MAPA GLOBAL ID_CAMPO -> Nombre de Campo
      /// =====================================================
      final Map<String, String> nombresCamposConfigurables = {};

      for (final tipoTela in listaTiposTela) {
        if (tipoTela.camposConfigurables != null) {
          for (final campo in tipoTela.camposConfigurables) {
            nombresCamposConfigurables[campo.id] = campo.nombre;
          }
        }
      }

      /// =====================================================
      /// FASE 1: AGRUPACIÓN CON FILTRADO DE LLAVE DIRECTO
      /// =====================================================
      final Map<String, List<StockActual>> rollosAgrupados = {};

      for (var item in rollosCerrados) {
        final colorKey = item.colorId ?? 'SIN_COLOR';

        // Localizamos de forma segura el TipoTela asociado al rollo actual
        TipoTela? tipoTelaItem;
        try {
          tipoTelaItem = listaTiposTela.firstWhere(
            (t) => t.id == item.tipoTelaId,
          );
        } catch (_) {
          tipoTelaItem = null;
        }

        final List<String> listaDifs = [];

        if (tipoTelaItem != null && tipoTelaItem.camposConfigurables != null) {
          for (final campo in tipoTelaItem.camposConfigurables) {
            if (campo.esDiferenciador == true) {
              // Caso 1: El valor diferenciador reside en atributosEspeciales del rollo (Milenium)
              if (item.atributosEspeciales != null &&
                  item.atributosEspeciales.containsKey(campo.id)) {
                final valor = item.atributosEspeciales[campo.id];
                listaDifs.add('${campo.id}:$valor');
              }
              // Caso 2: El valor viene directamente de las variantes del catálogo estructural (MAGITEX, Piel de Sirena)
              else if (tipoTelaItem.variantes != null &&
                  tipoTelaItem.variantes.isNotEmpty) {
                final primeraVariante = tipoTelaItem.variantes.first;
                if (primeraVariante.campos != null) {
                  try {
                    final campoVar = primeraVariante.campos.firstWhere(
                      (c) => c.campoId == campo.id,
                    );
                    listaDifs.add('${campo.id}:${campoVar.valor}');
                  } catch (_) {}
                }
              }
            }
          }
        }

        String fragmentoDiferenciador = '';
        if (listaDifs.isNotEmpty) {
          listaDifs.sort();
          fragmentoDiferenciador = '_${listaDifs.join('_')}';
        }

        final groupKey =
            '${item.tipoTelaId}_${colorKey}$fragmentoDiferenciador';
        rollosAgrupados.putIfAbsent(groupKey, () => []).add(item);
      }

      /// =====================================================
      /// FASE 2: CONSTRUCCIÓN DEL MODELO DE UI FINAL
      /// =====================================================
      final List<TraspasoGrupoUi> resultadoEnMemoria = [];

      for (var entry in rollosAgrupados.entries) {
        final groupKey = entry.key;
        final rollos = entry.value;
        final primerRollo = rollos.first;

        final colorMaestro = listaColores.firstWhere(
          (c) => c.id == primerRollo.colorId,
          orElse: () => ColorTela(
            id: '',
            empresaId: '',
            nombre: 'Sin Color',
            hexadecimal: 'CCCCCC',
          ),
        );

        final tipoTelaMaestro = listaTiposTela.firstWhere(
          (t) => t.id == primerRollo.tipoTelaId,
          orElse: () => TipoTela(
            id: '',
            empresaId: '',
            nombre: 'Desconocido (${primerRollo.tipoTelaId})',
          ),
        );

        String? codigoUnicoEncontrado;
        try {
          final registroProveedor = listaCodigosUnicos.firstWhere(
            (c) => c.tipoTelaId == primerRollo.tipoTelaId,
          );
          final colorCodigo = registroProveedor.colores.firstWhere(
            (cc) => cc.colorId == primerRollo.colorId,
          );
          codigoUnicoEncontrado = colorCodigo.codigoColor;
        } catch (_) {
          codigoUnicoEncontrado = null;
        }

        /// =====================================================
        /// DIFERENCIADORES DE CABECERA (SEGURO Y DETERMINÍSTICO)
        /// =====================================================
        final Map<String, String> valoresDiferenciadoresGrupo = {};

        if (tipoTelaMaestro.camposConfigurables != null) {
          for (final campo in tipoTelaMaestro.camposConfigurables) {
            if (campo.esDiferenciador == true) {
              // Primero intentamos extraerlo desde atributosEspeciales
              if (primerRollo.atributosEspeciales != null &&
                  primerRollo.atributosEspeciales.containsKey(campo.id)) {
                valoresDiferenciadoresGrupo[campo.nombre] = primerRollo
                    .atributosEspeciales[campo.id]
                    .toString();
              }
              // Fallback directo desde el catálogo de variantes de TipoTela
              else if (tipoTelaMaestro.variantes != null &&
                  tipoTelaMaestro.variantes.isNotEmpty) {
                final primeraVariante = tipoTelaMaestro.variantes.first;
                if (primeraVariante.campos != null) {
                  try {
                    final campoVar = primeraVariante.campos.firstWhere(
                      (c) => c.campoId == campo.id,
                    );
                    valoresDiferenciadoresGrupo[campo.nombre] = campoVar.valor
                        .toString();
                  } catch (_) {}
                }
              }
            }
          }
        }

        print('--- DIFERENCIADORES DESDE PROVIDER ---');
        if (valoresDiferenciadoresGrupo.isEmpty) {
          print('VACIO');
        } else {
          valoresDiferenciadoresGrupo.forEach((k, v) {
            print('$k => $v');
          });
        }

        resultadoEnMemoria.add(
          TraspasoGrupoUi(
            groupKey: groupKey,
            tipoTelaNombre: tipoTelaMaestro.nombre,
            colorNombre: colorMaestro.nombre,
            flutterColor: colorMaestro.toFlutterColor,
            codigoUnicoProveedor: codigoUnicoEncontrado,
            rollos: rollos,
            nombresCamposConfigurables: nombresCamposConfigurables,
            valoresDiferenciadoresGrupo: valoresDiferenciadoresGrupo,
          ),
        );
      }

      return AsyncValue.data(resultadoEnMemoria);
    });
