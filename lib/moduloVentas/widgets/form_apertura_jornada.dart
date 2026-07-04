import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/moduloVentas/widgets/apertura_jornada_dialog.dart';
import 'package:inv_telas/providers/ventas_provider.dart';
import 'package:inv_telas/providers/ventas_sucursal_provider.dart';

class FormAperturaJornada extends ConsumerWidget {
  const FormAperturaJornada({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final empresa = session.empresaActual?.nombre ?? 'Sin empresa';
    final empresaId = session.empresaActual?.id ?? '';
    final usuarioId = session.usuario?.id ?? '';

    final sucursalId = session.sucursalActual?.sucursalId ?? 'Sin sucursal';

    final jornadaState = ref.watch(jornadaActivaProvider(sucursalId));
    final ultimaJornadaRegistrada = jornadaState.value;

    // 1. Obtenemos la fecha de hoy en formato YYYY-MM-DD
    final ahora = DateTime.now();
    final fechaHoy =
        "${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}";

    // 2. Evaluamos si es candidata a reapertura SOLO si pertenece a la fecha de hoy
    final bool esReaperturaCandidata =
        ultimaJornadaRegistrada != null &&
        !ultimaJornadaRegistrada.abierta &&
        ultimaJornadaRegistrada.fechaDia == fechaHoy; // 👈 NUEVA VALIDACIÓN

    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.point_of_sale, size: 80),
              const SizedBox(height: 15),
              Text(
                esReaperturaCandidata
                    ? 'Jornada de hoy se encuentra cerrada'
                    : 'No existe una jornada abierta',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text('Empresa: $empresa'),
              Text('Sucursal: $sucursalId'),
              if (esReaperturaCandidata) ...[
                const SizedBox(height: 8),
                Text(
                  'Reaperturas consumidas: ${ultimaJornadaRegistrada.reaperturas} de 2 disponibles.',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon: Icon(
                  esReaperturaCandidata ? Icons.refresh : Icons.lock_open,
                ),
                label: Text(
                  esReaperturaCandidata ? 'Reabrir Jornada' : 'Abrir Jornada',
                ),
                onPressed: () async {
                  if (esReaperturaCandidata) {
                    // Acción Directa: Reabrir jornada existente (Máximo 2 veces)
                    try {
                      await ref
                          .read(jornadaActivaProvider(sucursalId).notifier)
                          .reabrirJornadaExistente();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Jornada reabierta exitosamente.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Operación Denegada'),
                            content: Text(
                              e.toString().replaceAll("Exception: ", ""),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      }
                    }
                  } else {
                    // Acción Nueva: Mostrar el cuadro de diálogo para registrar caja y tipo de cambio
                    final resultado = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (_) => const AperturaJornadaDialog(),
                    );

                    if (resultado == null) return;

                    try {
                      await ref
                          .read(jornadaActivaProvider(sucursalId).notifier)
                          .inicializarApertura(
                            empresaId: empresaId,
                            usuarioId: usuarioId,
                            tc: resultado['tipoCambio'] ?? 6.96,
                            cajaInicial: resultado['montoInicial'] ?? 0.0,
                          );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
