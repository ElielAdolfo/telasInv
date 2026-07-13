// lib/moduloPrecios/screens/precios_sucursal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/session_provider.dart';
import '../../providers/tipo_tela_provider.dart';
import '../../providers/precio_venta_provider.dart';
import '../widgets/formulario_precio_dialog.dart';
import 'package:collection/collection.dart';

class PreciosSucursalScreen extends ConsumerWidget {
  const PreciosSucursalScreen({super.key});

  // Helper para formatear valores opcionales de forma limpia
  String _formatearOpcional(
    double? precio, {
    double? metros,
    bool esEscala = false,
  }) {
    if (precio == null) return 'No configurado';

    final precioFormateado = 'Bs. ${precio.toStringAsFixed(2)}';
    if (esEscala && metros != null) {
      return '$precioFormateado /m (Desde ${metros.toStringAsFixed(0)}m)';
    }
    return precioFormateado;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final empresaId = session.empresaActual?.id ?? '';

    final tiposTelaAsync = ref.watch(tiposTelaStreamProvider(empresaId));
    final preciosAsync = ref.watch(preciosVentaSucursalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Precios por Sucursal'),
      ),
      body: empresaId.isEmpty
          ? const Center(
              child: Text('No se ha seleccionado una empresa activa.'),
            )
          : tiposTelaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error cargando telas: $e')),
              data: (telas) {
                return preciosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error cargando precios: $e')),
                  data: (preciosConfigurados) {
                    if (telas.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay tipos de telas registrados en el sistema.',
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: telas.length,
                      itemBuilder: (context, index) {
                        final tela = telas[index];
                        final precioConfig = preciosConfigurados
                            .firstWhereOrNull((p) => p.tipoTelaId == tela.id);

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              tela.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: precioConfig == null
                                  ? const Text(
                                      '⚠️ SIN PRECIO ASIGNADO (Bloqueado para la venta)',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '• Al detalle: Bs. ${precioConfig.precioVentaMetro.toStringAsFixed(2)} /m',
                                        ),
                                        Text(
                                          '• Por Mayor: ${_formatearOpcional(precioConfig.precioVentaXMayor, metros: precioConfig.metrosMinimoXMayor, esEscala: true)}',
                                        ),
                                        Text(
                                          '• Súper Mayor: ${_formatearOpcional(precioConfig.precioVentaSuperMayor, metros: precioConfig.metrosMinimoSuperMayor, esEscala: true)}',
                                        ),
                                        Text(
                                          '• Por Rollo: ${_formatearOpcional(precioConfig.precioXRollo)}',
                                        ),
                                      ],
                                    ),
                            ),
                            trailing: ElevatedButton.icon(
                              icon: Icon(
                                precioConfig == null ? Icons.add : Icons.edit,
                              ),
                              label: Text(
                                precioConfig == null ? 'Asignar' : 'Modificar',
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => FormularioPrecioDialog(
                                    tipoTelaId: tela.id,
                                    nombreTela: tela.nombre,
                                    precioExistente: precioConfig,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
