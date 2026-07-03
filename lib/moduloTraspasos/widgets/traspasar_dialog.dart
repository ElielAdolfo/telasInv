import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import '../../widgets/confirm_action_dialog.dart';
import '../../providers/traspaso_provider.dart';
import '../../providers/sucursal_provider.dart';
import '../../providers/auth_provider.dart'; // Asumiendo que extraes el usuario actual desde aquí

class TraspasarDialog extends ConsumerStatefulWidget {
  final List<String> stockIds;
  final VoidCallback onTraspasoExitoso;

  const TraspasarDialog({
    super.key,
    required this.stockIds,
    required this.onTraspasoExitoso,
  });

  @override
  ConsumerState<TraspasarDialog> createState() => _TraspasarDialogState();
}

class _TraspasarDialogState extends ConsumerState<TraspasarDialog> {
  String? _sucursalDestinoId;

  @override
  Widget build(BuildContext context) {
    
    final session = ref.read(sessionProvider);
    final empresa = session.empresaActual;
    // Reutilizando el provider de sucursales de tu proyecto (se asume una empresa fija o activa global)
    final sucursalesAsync = ref.watch(sucursalesProvider(empresa!.id));
    final currentSucursalOrigen = ref.read(traspasoProvider).sucursalOrigenId;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.local_shipping, color: Colors.indigo),
          SizedBox(width: 10),
          Text('Destino del Traspaso'),
        ],
      ),
      content: sucursalesAsync.when(
        data: (sucursales) {
          // Filtrar para no traspasar a la misma sucursal origen
          final opciones = sucursales
              .where((s) => s.id != currentSucursalOrigen)
              .toList();

          if (opciones.isEmpty) {
            return const Text(
              'No hay otras sucursales disponibles para realizar el traspaso.',
            );
          }

          return DropdownButtonFormField<String>(
            value: _sucursalDestinoId,
            hint: const Text('Seleccionar sucursal destino'),
            items: opciones
                .map(
                  (s) => DropdownMenuItem(value: s.id, child: Text(s.nombre)),
                )
                .toList(),
            onChanged: (val) => setState(() => _sucursalDestinoId = val),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          );
        },
        loading: () => const SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Error al cargar sucursales: $e'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _sucursalDestinoId == null
              ? null
              : () async {
                  final confirmado = await showDialog<bool>(
                    context: context,
                    builder: (context) => ConfirmActionDialog(
                      title: 'Confirmar Traspaso',
                      message:
                          '¿Está seguro de traspasar ${widget.stockIds.length} rollo(s) a la sucursal seleccionada?',
                      icon: Icons.swap_horiz,
                      iconColor: Colors.indigo,
                      onConfirm: () async {
                        final uid =
                            ref.read(authProvider).value?.id ?? 'sistema';
                        await ref
                            .read(traspasoServiceProvider)
                            .ejecutarTraspasoMasivo(
                              stockIds: widget.stockIds,
                              nuevaSucursalId: _sucursalDestinoId!,
                              usuarioId: uid,
                            );
                      },
                    ),
                  );

                  if (confirmado == true) {
                    widget.onTraspasoExitoso();
                    if (mounted) Navigator.pop(context);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          child: const Text('Continuar'),
        ),
      ],
    );
  }
}
