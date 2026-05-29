import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

import 'sucursal_form_dialog.dart';

class SucursalCard extends ConsumerWidget {
  final Sucursal sucursal;

  const SucursalCard({super.key, required this.sucursal});

  Future<void> _eliminar(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: 'Eliminar sucursal',
        message: '¿Desea eliminar la sucursal "${sucursal.nombre}"?',
        icon: Icons.delete,
        iconColor: Colors.red,
        onConfirm: () async {},
      ),
    );

    if (confirm != true) return;

    final userId = ref.read(currentUserProvider).id;

    await ref
        .read(sucursalServiceProvider)
        .eliminarSucursal(id: sucursal.id, usuarioId: userId);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sucursal eliminada')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: const Icon(Icons.store)),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    sucursal.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'editar') {
                      await showDialog(
                        context: context,
                        builder: (_) => SucursalFormDialog(sucursal: sucursal),
                      );
                    }

                    if (value == 'eliminar') {
                      _eliminar(context, ref);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'editar', child: Text('Editar')),
                    PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(sucursal.direccion),

            if (sucursal.whatsapp != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('WhatsApp: ${sucursal.whatsapp}'),
              ),

            if (sucursal.nit != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('NIT: ${sucursal.nit}'),
              ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text('Activo'),
            ),
          ],
        ),
      ),
    );
  }
}
