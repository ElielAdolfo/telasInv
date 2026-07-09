import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/ventas/stock_actual.dart';
import 'package:inv_telas/moduloVentas/widgets/carrito_ventas_panel.dart';
import 'package:inv_telas/moduloVentas/widgets/form_apertura_jornada.dart';
import 'package:inv_telas/moduloVentas/widgets/resumen_jornada_card.dart';
import 'package:inv_telas/moduloVentas/widgets/venta_grupo_card.dart';
import 'package:inv_telas/providers/pos_autorizacion_provider.dart';
import 'package:inv_telas/providers/stock_actual_provider.dart';
import 'package:inv_telas/providers/venta_tipo_tela_provider.dart';
import 'package:inv_telas/providers/ventas_provider.dart';
import 'package:inv_telas/providers/ventas_tipo_tela_nombre_provider.dart';

class VentasPosScreen extends ConsumerWidget {
  const VentasPosScreen({super.key});

  String _obtenerFechaActualString() {
    final ahora = DateTime.now();
    return "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";
  }

  void _mostrarDialogoCierre(
    BuildContext context,
    WidgetRef ref,
    String sucursalId,
  ) {
    final cajaCtrl = TextEditingController();
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cerrar Jornada'),
          content: TextFormField(
            controller: cajaCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Monto Final en Caja (Bs)',
              border: OutlineInputBorder(),
              prefixText: 'Bs ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => navigator.pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final monto = double.tryParse(cajaCtrl.text) ?? 0.0;

                await ref
                    .read(jornadaActivaProvider(sucursalId).notifier)
                    .cerrarJornadaEnCaja(monto);

                navigator.pop();
              },
              child: const Text('Confirmar Cierre'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJornadaBloqueada(
    BuildContext context,
    WidgetRef ref,
    String sucursalId,
    String fechaJornada,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Bloqueado'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'USTED TIENE UNA JORNADA ABIERTA DE OTRO DÍA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fecha de jornada: $fechaJornada\n'
                  'Debe cerrar esta jornada antes de continuar o vender.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                  ),
                  icon: const Icon(Icons.lock),
                  label: const Text('Cerrar Jornada Pendiente'),
                  onPressed: () =>
                      _mostrarDialogoCierre(context, ref, sucursalId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    final sucursalId = session.sucursalActual?.sucursalId ?? '';
    final empresaId = session.empresaActual?.id ?? '';

    if (sucursalId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No existe una sucursal seleccionada para ventas'),
        ),
      );
    }

    /// 🔐 PERMISO DE VENTA
    final authAsync = ref.watch(posAutorizacionProvider(sucursalId));

    return authAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error permisos: $e'))),

      data: (puedeVender) {
        if (!puedeVender) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Usted no está autorizado a vender en esta sucursal',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        /// 🟡 JORNADA
        final jAsync = ref.watch(jornadaActivaProvider(sucursalId));

        return jAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),

          error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),

          data: (jornada) {
            final fechaHoy = _obtenerFechaActualString();

            /// 🚨 BLOQUEO POR JORNADA DE OTRO DÍA
            if (jornada != null &&
                jornada.abierta &&
                jornada.fechaDia != fechaHoy) {
              return _buildJornadaBloqueada(
                context,
                ref,
                sucursalId,
                jornada.fechaDia,
              );
            }

            /// 🔓 SIN JORNADA
            if (jornada == null || !jornada.abierta) {
              return const Scaffold(body: Center(child: FormAperturaJornada()));
            }

            /// 🟢 POS NORMAL
            final tipoTelaSeleccionada = ref.watch(
              tipoTelaSeleccionadaProvider,
            );

            final tiposDisponiblesAsync = ref.watch(
              tiposTelaDisponiblesProvider(sucursalId),
            );

            final mapaTiposAsync = ref.watch(
              ventasMapaTiposTelaProvider(empresaId),
            );

            final mapaTiposArray = mapaTiposAsync.value ?? {};

            return Scaffold(
              body: Column(
                children: [
                  ResumenJornadaCard(
                    jornada: jornada,
                    onCerrar: () =>
                        _mostrarDialogoCierre(context, ref, sucursalId),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: tiposDisponiblesAsync.when(
                      loading: () => const LinearProgressIndicator(),

                      error: (e, _) => Text('Error cargando tipos: $e'),

                      data: (tipos) {
                        return mapaTiposAsync.when(
                          loading: () => const LinearProgressIndicator(),

                          error: (_, __) => const SizedBox(),

                          data: (mapaTipos) {
                            return DropdownButtonFormField<String>(
                              initialValue: tipoTelaSeleccionada,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Tela',
                                border: OutlineInputBorder(),
                              ),
                              items: tipos.map((id) {
                                final tela = mapaTipos[id];

                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(tela?.nombre ?? id),
                                );
                              }).toList(),
                              onChanged: (value) {
                                ref
                                        .read(
                                          tipoTelaSeleccionadaProvider.notifier,
                                        )
                                        .state =
                                    value;
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final esWeb = constraints.maxWidth > 850;

                        final catalogoWidget = tipoTelaSeleccionada == null
                            ? const Center(
                                child: Text('Seleccione un tipo de tela'),
                              )
                            : ref
                                  .watch(
                                    stockPorTipoProvider((
                                      sucursalId: sucursalId,
                                      tipoTelaId: tipoTelaSeleccionada,
                                    )),
                                  )
                                  .when(
                                    loading: () => const Center(
                                      child: CircularProgressIndicator(),
                                    ),

                                    error: (e, _) =>
                                        Center(child: Text('Error stock: $e')),

                                    data: (lista) {
                                      final Map<String, List<StockActual>>
                                      grupos = {};

                                      for (final item in lista) {
                                        final key =
                                            '${item.tipoTelaId}_${item.colorId ?? "std"}_${item.loteId}';

                                        grupos
                                            .putIfAbsent(key, () => [])
                                            .add(item);
                                      }

                                      return ListView.builder(
                                        itemCount: grupos.length,
                                        itemBuilder: (context, index) {
                                          final key = grupos.keys.elementAt(
                                            index,
                                          );

                                          final grupo = grupos[key]!;

                                          final nombreTela =
                                              mapaTiposArray[grupo
                                                      .first
                                                      .tipoTelaId]
                                                  ?.nombre ??
                                              grupo.first.tipoTelaId;
                                          return VentaGrupoCard(
                                            tipoTelaId: grupo.first.tipoTelaId,
                                            colorId: grupo.first.colorId,
                                            loteId: grupo.first.loteId,
                                            rollosGrupo: grupo,
                                            nombreTela: nombreTela,
                                          );
                                        },
                                      );
                                    },
                                  );
                        final carritoWidget = CarritoVentasPanel(
                          jornadaAbierta: jornada.abierta,
                          mapaTiposTela: mapaTiposArray,
                          onConfirmar: () {
                            debugPrint('Procesar venta jornada ${jornada.id}');
                          },
                        );

                        if (esWeb) {
                          return Row(
                            children: [
                              Expanded(flex: 3, child: catalogoWidget),

                              VerticalDivider(
                                width: 1,
                                color: Colors.grey.shade300,
                              ),

                              SizedBox(width: 360, child: carritoWidget),
                            ],
                          );
                        }

                        return Stack(
                          children: [
                            catalogoWidget,

                            Positioned(
                              bottom: 16,
                              right: 16,
                              child: FloatingActionButton(
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (_) => SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.80,
                                      child: carritoWidget,
                                    ),
                                  );
                                },
                                child: const Icon(Icons.shopping_cart),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
