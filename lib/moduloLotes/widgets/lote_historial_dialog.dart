import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import '../../../providers/lote_provider.dart';
import '../../../providers/usuario_provider.dart'; // Asegúrate de importar el archivo donde está usuarioProvider

class LoteHistorialDialog extends ConsumerWidget {
  final String loteId;

  const LoteHistorialDialog({super.key, required this.loteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Buscamos primero el lote dentro de nuestra lista cargada en el provider general
    //    Esto nos da acceso inmediato a la fecha de creación y al ID del creador sin hacer otra petición a Firebase.

    final session = ref.watch(sessionProvider);

    final empresa = session.empresaActual;
    final lotesAsync = ref.watch(lotesProvider(empresa!.id));

    return Dialog(
      child: SizedBox(
        width: 800,
        height: 550,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: lotesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (lotes) {
              // Localizamos el lote específico asignado a este diálogo
              final lote = lotes.firstWhere((l) => l.id == loteId);

              // 2. Usamos el ID del creador para vigilar el estado del usuario asíncronamente
              final creadorAsync = ref.watch(
                usuarioProvider(lote.usuarioCreacion),
              );

              // Formateamos la fecha manualmente en DD/MM/YYYY
              final fecha = lote.fechaCreacion;
              final dia = fecha.day.toString().padLeft(2, '0');
              final mes = fecha.month.toString().padLeft(2, '0');
              final anio = fecha.year;
              final fechaFormateada = '$dia/$mes/$anio';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.history),
                      const SizedBox(width: 10),
                      Text(
                        'Historial del Lote: ${lote.numeroLote}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // Sección informativa del Creador y Fecha requeridos
                  Card(
                    margin: EdgeInsets.zero,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Manejamos los estados de la carga del Usuario Creador
                          creadorAsync.when(
                            loading: () => const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Cargando datos del creador...'),
                              ],
                            ),
                            error: (_, __) => const Text(
                              'Creador: Desconocido o error al cargar',
                            ),
                            data: (usuario) {
                              return Text(
                                'Creador: ${usuario?.nombre ?? 'No identificado'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Fecha creación: $fechaFormateada',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
