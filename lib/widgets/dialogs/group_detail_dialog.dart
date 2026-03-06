import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';

class GroupDetailDialog extends ConsumerWidget {
  final Map<String, dynamic> grupo;
  const GroupDetailDialog({super.key, required this.grupo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rollos = (grupo['rollos'] as List<Rollo>?) ?? [];
    final sucursales = ref.watch(sucursalesProvider);

    // Resolvemos nombres para el título
    final colorId = grupo['colorId'];
    final colorNombre = ref
        .read(coloresProvider)
        .firstWhere(
          (c) => c.id == colorId,
          orElse: () => ColorTela(id: '', nombre: 'Color'),
        )
        .nombre;

    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rollos: $colorNombre", style: AppTextStyles.heading2),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _InfoBox(label: "Rollos", value: "${grupo['cantidad']}"),
                _InfoBox(
                  label: "Metraje",
                  value:
                      "${(grupo['metrajeTotal'] as double).toStringAsFixed(1)} m",
                ),
                _InfoBox(
                  label: "Sucursales",
                  value: "${(grupo['sucursales'] as List? ?? []).length}",
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: rollos.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final r = rollos[i];
                  // Obtenemos nombre de sucursal para mostrar
                  final sucursalNombre = sucursales
                      .firstWhere(
                        (s) => s.id == r.sucursalId,
                        orElse: () => Sucursal(id: '', nombre: 'Sin Asignar'),
                      )
                      .nombre;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        "${i + 1}",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text("${r.codigoColor} - $sucursalNombre"),
                    subtitle: Text("${r.metraje} m"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit_location_alt,
                            color: Colors.blue,
                          ),
                          onPressed: () => _editSucursal(context, ref, r),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _delete(context, ref, r.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editSucursal(BuildContext context, WidgetRef ref, Rollo rollo) async {
    final sucursales = ref.read(sucursalesProvider);
    String? selectedId = rollo.sucursalId;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mover Rollo"),
        content: DropdownButtonFormField<String>(
          value: selectedId,
          items: sucursales
              .map(
                (s) => DropdownMenuItem(
                  value: s.id, // Valor es ID
                  child: Text(s.nombre), // Texto es Nombre
                ),
              )
              .toList(),
          onChanged: (v) => selectedId = v,
          decoration: const InputDecoration(labelText: "Sucursal Destino"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Pasamos el ID al servicio
              await ref
                  .read(rollosProvider.notifier)
                  .actualizarSucursal(rollo.id, selectedId);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("Mover"),
          ),
        ],
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      titulo: "¿Eliminar?",
      mensaje: "Esta acción no se puede deshacer",
      isDanger: true,
    );
    if (confirm == true) {
      await ref.read(rollosProvider.notifier).eliminarRollo(id);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
