import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/moduloVentas/widgets/form_apertura_jornada.dart';
import 'package:inv_telas/providers/pos_autorizacion_provider.dart';
import 'package:inv_telas/providers/ventas_provider.dart';
import 'package:inv_telas/providers/ventas_sucursal_provider.dart';

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
    // Guardamos la referencia del Navigator antes del proceso asíncrono
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Cerrar Caja de la Jornada'),
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

                // Cerramos de forma segura usando el Navigator pre-guardado
                navigator.pop();
              },
              child: const Text('Confirmar Cierre'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. OBSERVAMOS la sucursal de forma reactiva y síncrona
    final session = ref.watch(sessionProvider);

    final sucursalId = session.sucursalActual?.sucursalId ?? '';

    print('======================');
    print('VENTAS POS BUILD');
    print('Sucursal actual: "$sucursalId"');
    print('======================');

    // 2. Escucha en background para efectos secundarios
    ref.listen<String?>(sucursalVentaSeleccionadaProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        print('==================================================');
        print('🔥 [VentasPosScreen] ¡La sucursal ha cambiado en background!');
        print('Anterior: $previous | Nueva: $next');
        print('==================================================');
      }
    });

    // 3. Validación inmediata si no hay sucursal seleccionada
    if (sucursalId.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No existe una sucursal seleccionada para ventas'),
        ),
      );
    }

    final empresaId = session.empresaActual?.id ?? '';

    /// 🔐 VALIDACIÓN DE PERMISO DE VENTA REACTIVA
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
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        /// 🔥 JORNADA (También reactiva a la sucursal actual)
        final jAsync = ref.watch(jornadaActivaProvider(sucursalId));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Módulo de Ventas / Facturación POS'),
          ),
          body: jAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (jornada) {
              final fechaHoyStr = _obtenerFechaActualString();

              /// 🚨 Jornada abierta de otro día
              if (jornada != null &&
                  jornada.abierta &&
                  jornada.fechaDia != fechaHoyStr) {
                return Center(
                  child: Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 80,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tiene una jornada abierta del día anterior (${jornada.fechaDia})',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Debe cerrarla antes de continuar.',
                            textAlign: TextAlign.center,
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
                );
              }

              /// 🔓 Sin jornada activa (Requiere Apertura)
              if (jornada == null || !jornada.abierta) {
                return const Center(child: FormAperturaJornada());
              }

              /// 🟢 POS NORMAL (Autorizado y con Jornada al día)
              return Column(
                children: [
                  Container(
                    color: Colors.amber.shade700,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.monetization_on,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "TIPO DE CAMBIO: 1 USD = ${jornada.tipoCambio.toStringAsFixed(2)} Bs. | Reaperturas ${jornada.reaperturas}/2",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade900,
                          ),
                          icon: const Icon(Icons.lock_clock),
                          label: const Text('Cerrar Jornada'),
                          onPressed: () =>
                              _mostrarDialogoCierre(context, ref, sucursalId),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'POS activo\nSucursal: $sucursalId\nEmpresa: $empresaId\nJornada: ${jornada.id}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
