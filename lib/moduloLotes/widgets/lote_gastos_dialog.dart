import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/lotes/gastos.dart';

import '../../providers/lote_gastos_provider.dart';
import '../../providers/gasto_provider.dart';

import 'lote_gasto_agrupado_card.dart';
import 'nuevo_gasto_dialog.dart';

class LoteGastosDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final String loteId;

  const LoteGastosDialog({
    super.key,
    required this.empresaId,
    required this.loteId,
  });

  @override
  ConsumerState<LoteGastosDialog> createState() => _LoteGastosDialogState();
}

class _LoteGastosDialogState extends ConsumerState<LoteGastosDialog> {
  // --- VARIABLES PARA EL EFECTO DE PARPADEO INTERACTIVO ---
  String? _loteDetalleResaltadoId;
  bool _mostrarColorParpadeo = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final args = (empresaId: widget.empresaId, loteId: widget.loteId);

      await Future.wait([
        ref
            .read(loteGastosProvider.notifier)
            .cargarYAgruparConsola(
              empresaId: widget.empresaId,
              loteId: widget.loteId,
            ),
        ref.read(gastosLoteProvider(args).notifier).cargarGastos(),
      ]);
    });
  }

  // FUNCIÓN ASÍNCRONA PARA DISPARAR EL PARPADEO 3 VECES (Alternando 6 veces el estado)
  void _ejecutarParpadeo(String loteDetalleId) async {
    setState(() {
      _loteDetalleResaltadoId = loteDetalleId;
      _mostrarColorParpadeo = true;
    });

    for (int i = 0; i < 6; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;
      setState(() {
        _mostrarColorParpadeo = !_mostrarColorParpadeo;
      });
    }

    setState(() {
      _loteDetalleResaltadoId = null;
      _mostrarColorParpadeo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loteGastosProvider);
    final args = (empresaId: widget.empresaId, loteId: widget.loteId);
    final gastosState = ref.watch(gastosLoteProvider(args));

    return LayoutBuilder(
      builder: (context, constraints) {
        final esCelular = constraints.maxWidth < 900;

        return Dialog(
          insetPadding: esCelular
              ? const EdgeInsets.all(10)
              : const EdgeInsets.all(24),
          child: SizedBox(
            width: esCelular ? double.infinity : 1300,
            height: esCelular ? double.infinity : 700,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 10),
                  const Divider(),
                  Expanded(
                    child: esCelular
                        ? _buildMobileLayout(state, gastosState)
                        : _buildDesktopLayout(state, gastosState),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.receipt_long),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            "Costos y Gastos del Lote",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Añadir gasto"),
          onPressed: () async {
            final session = ref.read(sessionProvider);
            final empresa = session.empresaActual;

            final guardado = await showDialog<bool>(
              context: context,
              builder: (_) => NuevoGastoDialog(
                empresaId: empresa!.id,
                loteId: widget.loteId,
              ),
            );

            if (guardado == true) {
              await ref
                  .read(
                    gastosLoteProvider((
                      empresaId: widget.empresaId,
                      loteId: widget.loteId,
                    )).notifier,
                  )
                  .cargarGastos();

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gasto registrado correctamente')),
              );
            }
          },
        ),
        const SizedBox(width: 10),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    LoteGastosState costos,
    AsyncValue<List<Gasto>> gastos,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildPanelCostos(costos, gastos, esCelular: false),
        ),
        const VerticalDivider(width: 20),
        Expanded(child: _buildPanelGastos(costos, gastos, esCelular: false)),
      ],
    );
  }

  Widget _buildMobileLayout(
    LoteGastosState costos,
    AsyncValue<List<Gasto>> gastos,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelCostos(costos, gastos, esCelular: true),
          const SizedBox(height: 16),
          _buildPanelGastos(costos, gastos, esCelular: true),
        ],
      ),
    );
  }

  Widget _buildPanelCostos(
    LoteGastosState state,
    AsyncValue<List<Gasto>> gastosState, {
    required bool esCelular,
  }) {
    final contenido = state.cargando
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        : state.error != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(state.error!),
            ),
          )
        : state.agrupados.isEmpty
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text("Sin datos"),
            ),
          )
        : ListView.builder(
            shrinkWrap: esCelular,
            physics: esCelular ? const NeverScrollableScrollPhysics() : null,
            itemCount: state.agrupados.length,
            itemBuilder: (_, index) {
              final item = state.agrupados[index];

              int cantidadGastosTransporte = 0;
              gastosState.whenData((listaGastos) {
                cantidadGastosTransporte = listaGastos
                    .where((g) => g.loteDetalleId == item.loteDetalleId)
                    .length;
              });

              return Stack(
                children: [
                  LoteGastoAgrupadoCard(item: item),
                  if (cantidadGastosTransporte > 0)
                    Positioned(
                      top: 18,
                      right: 14,
                      child: InkWell(
                        onTap: () => _ejecutarParpadeo(item.loteDetalleId),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.amber.shade300,
                              width: 1.2,
                            ),
                          ),
                          child: cantidadGastosTransporte == 1
                              ? Icon(
                                  Icons.local_shipping,
                                  color: Colors.amber.shade700,
                                  size: 22,
                                )
                              : Badge(
                                  backgroundColor: Colors.amber.shade800,
                                  label: Text(
                                    '$cantidadGastosTransporte',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.amber.shade700,
                                    size: 22,
                                  ),
                                ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );

    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Costos calculados por tela",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          esCelular ? contenido : Expanded(child: contenido),
        ],
      ),
    );
  }

  Widget _buildPanelGastos(
    LoteGastosState costos,
    AsyncValue<List<Gasto>> gastos, {
    required bool esCelular,
  }) {
    return Card(
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: const Text(
              "Gastos manuales",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          gastos.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(e.toString()),
              ),
            ),
            data: (lista) {
              if (lista.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text("No existen gastos registrados"),
                  ),
                );
              }

              final total = lista.fold<double>(0, (sum, g) => sum + g.totalBs);

              // Construimos la lista internamente respetando el scroll dinámico según la plataforma
              final listadoWidgets = ListView.builder(
                shrinkWrap: esCelular,
                physics: esCelular
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: lista.length,
                itemBuilder: (_, i) {
                  final gasto = lista[i];
                  final tieneDetalleAsociado = gasto.loteDetalleId != null;

                  final debeParpadear =
                      tieneDetalleAsociado &&
                      gasto.loteDetalleId == _loteDetalleResaltadoId &&
                      _mostrarColorParpadeo;

                  final telaEncontrada = tieneDetalleAsociado
                      ? costos.agrupados.cast().firstWhere(
                          (t) => t.loteDetalleId == gasto.loteDetalleId,
                          orElse: () => null,
                        )
                      : null;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: debeParpadear
                          ? Colors.amber.shade300
                          : tieneDetalleAsociado
                          ? Colors.amber.withValues(alpha: 0.07)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: debeParpadear
                            ? Colors.amber.shade800
                            : tieneDetalleAsociado
                            ? Colors.amber.withValues(alpha: 0.3)
                            : Colors.transparent,
                        width: debeParpadear ? 2.0 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: tieneDetalleAsociado
                            ? Colors.amber.shade700
                            : Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        child: Icon(
                          tieneDetalleAsociado
                              ? Icons.local_shipping
                              : Icons.restaurant_menu,
                        ),
                      ),
                      title: Text(
                        gasto.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Moneda: ${gasto.monedaCodigo} • Orig: ${gasto.montoOrigen.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            if (tieneDetalleAsociado) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.inventory_2,
                                      size: 12,
                                      color: Colors.blue.shade800,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        telaEncontrada != null
                                            ? "${telaEncontrada.tipoTela} - ${telaEncontrada.proveedor} (${telaEncontrada.cantidadRollos} R.)"
                                            : "Tela enlazada (Detalle ID: ${gasto.loteDetalleId})",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Bs ${gasto.totalBs.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Editar',
                            onPressed: () async {
                              final guardado = await showDialog<bool>(
                                context: context,
                                builder: (_) => NuevoGastoDialog(
                                  empresaId: widget.empresaId,
                                  loteId: widget.loteId,
                                  gasto: gasto,
                                ),
                              );
                              if (guardado == true) {
                                await ref
                                    .read(
                                      gastosLoteProvider((
                                        empresaId: widget.empresaId,
                                        loteId: widget.loteId,
                                      )).notifier,
                                    )
                                    .cargarGastos();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              // CORRECCIÓN: Separamos el contenedor del Total y hacemos que la lista use todo el espacio restante con scroll independiente en Desktop
              final cuerpoGastos = Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.calculate),
                        const SizedBox(width: 10),
                        Text(
                          "Total gastos: Bs ${total.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  esCelular ? listadoWidgets : Expanded(child: listadoWidgets),
                ],
              );

              return esCelular ? cuerpoGastos : Expanded(child: cuerpoGastos);
            },
          ),
        ],
      ),
    );
  }
}
