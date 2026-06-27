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
        // En Escritorio se mantiene la estructura original de dos paneles fijos uno al lado del otro
        Expanded(flex: 2, child: _buildPanelCostos(costos, esCelular: false)),
        const VerticalDivider(width: 20),
        Expanded(child: _buildPanelGastos(gastos, esCelular: false)),
      ],
    );
  }

  // --- EL CAMBIO PRINCIPAL ESTÁ AQUÍ ---
  Widget _buildMobileLayout(
    LoteGastosState costos,
    AsyncValue<List<Gasto>> gastos,
  ) {
    // Un solo scroll view para toda la pantalla de Android
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelCostos(costos, esCelular: true),
          const SizedBox(height: 16),
          _buildPanelGastos(gastos, esCelular: true),
        ],
      ),
    );
  }

  Widget _buildPanelCostos(LoteGastosState state, {required bool esCelular}) {
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
            // Si es celular, se acopla al scroll padre. Si es web, mantiene su scroll independiente.
            shrinkWrap: esCelular,
            physics: esCelular ? const NeverScrollableScrollPhysics() : null,
            itemCount: state.agrupados.length,
            itemBuilder: (_, index) {
              return LoteGastoAgrupadoCard(item: state.agrupados[index]);
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
          // En móvil ya no usamos Expanded para que el Card crezca de forma natural según su contenido
          esCelular ? contenido : Expanded(child: contenido),
        ],
      ),
    );
  }

  Widget _buildPanelGastos(
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

              final cuerpoGastos = Column(
                mainAxisSize: MainAxisSize.min,
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
                  ListView.builder(
                    shrinkWrap:
                        true, // Crucial para integrarse al scroll unificado
                    physics:
                        const NeverScrollableScrollPhysics(), // Evita conflictos con el scroll de Android
                    itemCount: lista.length,
                    itemBuilder: (_, i) {
                      final gasto = lista[i];
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.money)),
                        title: Text(gasto.descripcion),
                        subtitle: Text(gasto.monedaCodigo),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Bs ${gasto.totalBs.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
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
                      );
                    },
                  ),
                ],
              );

              // Al igual que con los costos, quitamos el Expanded en entornos móviles
              return esCelular ? cuerpoGastos : Expanded(child: cuerpoGastos);
            },
          ),
        ],
      ),
    );
  }
}
