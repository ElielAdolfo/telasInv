import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/carrito_provider.dart';
import '../../models/ventas/stock_actual.dart';
import 'detalle_rollo_dialog.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'vender_rollo_dialog.dart';

// Definición del enum local o importado para el filtro de estados
enum FiltroRolloEstado { todos, cerrado, abierto }

final filtroEstadoProvider = StateProvider<FiltroRolloEstado>(
  (ref) => FiltroRolloEstado.todos,
);

class VentaGrupoCard extends ConsumerWidget {
  final String tipoTelaId;
  final String? colorId;
  final String loteId;
  final List<StockActual> rollosGrupo;
  final String nombreTela;

  const VentaGrupoCard({
    super.key,
    required this.tipoTelaId,
    required this.colorId,
    required this.loteId,
    required this.rollosGrupo,
    required this.nombreTela,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(carritoVentasProvider);
    final filtroActual = ref.watch(filtroEstadoProvider);

    // Rollos activos que no están vendidos
    final rollosActivos = rollosGrupo
        .where((r) => r.estado != StockRolloEstado.vendido)
        .toList();

    // Aplicación del filtro seleccionado por el usuario
    final rollosFiltrados = rollosActivos.where((rollo) {
      switch (filtroActual) {
        case FiltroRolloEstado.cerrado:
          return rollo.estado == StockRolloEstado.cerrado;
        case FiltroRolloEstado.abierto:
          return rollo.estado == StockRolloEstado.abierto;
        case FiltroRolloEstado.todos:
        default:
          return true;
      }
    }).toList();

    final totalMts = rollosActivos.fold(0.0, (sum, r) => sum + r.metrajeActual);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector Agradable y Simple de Estados (SegmentedButton)
            // Diseñado para convivir de forma nativa encima o debajo de los títulos
            Center(
              child: SegmentedButton<FiltroRolloEstado>(
                segments: const [
                  ButtonSegment(
                    value: FiltroRolloEstado.todos,
                    label: Text('Todos'),
                    icon: Icon(Icons.list_alt, size: 16),
                  ),
                  ButtonSegment(
                    value: FiltroRolloEstado.cerrado,
                    label: Text('Cerrados'),
                    icon: Icon(Icons.inventory_2_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: FiltroRolloEstado.abierto,
                    label: Text('Abiertos'),
                    icon: Icon(Icons.mode_edit_outline, size: 16),
                  ),
                ],
                selected: {filtroActual},
                onSelectionChanged: (Set<FiltroRolloEstado> nuevoFiltro) {
                  ref.read(filtroEstadoProvider.notifier).state =
                      nuevoFiltro.first;
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),

            // Listado de cada uno de los rollos filtrados
            if (rollosFiltrados.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No hay rollos con este estado.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...rollosFiltrados.map((rollo) {
                // Calcular cuántos metros de este rollo específico están en el carrito
                double metrosEnCarrito = 0.0;
                for (var item in cartState.items) {
                  for (var sel in item.rollosSeleccionados) {
                    if (sel.rolloId == rollo.id) {
                      metrosEnCarrito += sel.metrosExtraidos;
                    }
                  }
                }

                // REGLA DE NEGOCIO: ¿Está cerrado realmente en DB y además NO tiene operaciones en cola?
                final bool estaRealmenteCerrado =
                    rollo.estado == StockRolloEstado.cerrado;
                final bool tieneMetrosEnCarrito = metrosEnCarrito > 0;

                // Si se metió al carrito o cambió en DB, ya no califica para venta completa
                final bool mostrarBotonVentaCompleta =
                    estaRealmenteCerrado && !tieneMetrosEnCarrito;

                // Mostrar botón excepcional para "Abrir Rollo" manualmente en mesa
                final bool mostrarBotonAbrirManualmente =
                    estaRealmenteCerrado && !tieneMetrosEnCarrito;

                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.circle,
                    size: 10,
                    color:
                        tieneMetrosEnCarrito ||
                            rollo.estado == StockRolloEstado.abierto
                        ? Colors.green
                        : (rollo.estado == StockRolloEstado.sobra
                              ? Colors.orange
                              : Colors.blue),
                  ),
                  title: Text(
                    'Rollo #${rollo.numeroFisico} (${tieneMetrosEnCarrito ? "PROV. ABIERTO" : rollo.estado.nombre})',
                    style: TextStyle(
                      fontWeight: tieneMetrosEnCarrito
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${rollo.metrajeActual.toStringAsFixed(2)} m restantes',
                        ),
                        if (tieneMetrosEnCarrito)
                          TextSpan(
                            text:
                                ' - ${metrosEnCarrito.toStringAsFixed(2)} m carrito',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Botón Vender Rollo Completo (Condicional Dinámico)
                      if (mostrarBotonVentaCompleta)
                        IconButton(
                          icon: const Icon(
                            Icons.archive,
                            color: Colors.blueGrey,
                          ),
                          tooltip: 'Vender Rollo Completo',
                          onPressed: () => ref
                              .read(carritoVentasProvider.notifier)
                              .agregarRolloCompleto(
                                rollo: rollo,
                                nombre: nombreTela,
                                precio:
                                    500.0, // Cambiar por tu cálculo de precio real
                              ),
                        ),

                      // 2. Botón Excepcional: Forzar Apertura Manual en Mesa sin vender centímetro todavía
                      if (mostrarBotonAbrirManualmente)
                        IconButton(
                          icon: const Icon(
                            Icons.lock_open,
                            color: Colors.amber,
                          ),
                          tooltip: 'Cambiar Estado a Abierto en Mesa',
                          onPressed: () {
                            // Aquí llamas a tu backend/Firebase/Notifier para cambiar el estado del rollo
                            debugPrint(
                              'Forzando cambio de estado a ABIERTO para el rollo ID: ${rollo.id}',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Rollo #${rollo.numeroFisico} cambiado a ABIERTO.',
                                ),
                              ),
                            );
                          },
                        ),

                      // 3. Botón Info Trazabilidad
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        tooltip: 'Ver Info',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => DetalleRolloDialog(rollo: rollo),
                        ),
                      ),

                      // 4. Botón Cortar / Vender Metraje
                      IconButton(
                        icon: const Icon(Icons.cut, color: Colors.red),
                        tooltip: 'Vender metraje de este rollo',
                        onPressed: () => showDialog(
                          context: context,
                          builder: (_) => VenderRolloDialog(
                            rollo: rollo,
                            nombreTela: nombreTela,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
