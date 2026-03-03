import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';

class GroupListTile extends ConsumerWidget {
  final Map<String, dynamic> grupo;
  final VoidCallback onTap;

  const GroupListTile({super.key, required this.grupo, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = ref.watch(coloresProvider);
    final sucursales = ref.watch(sucursalesProvider);

    final colorHex = colores
        .firstWhere(
          (c) => c.nombre == grupo['color'],
          orElse: () => ColorTela(id: '', nombre: '', hex: '#94a3b8'),
        )
        .hex;

    final badges = (grupo['sucursales'] as List).map((s) {
      final sColor = sucursales
          .firstWhere(
            (su) => su.nombre == s,
            orElse: () => Sucursal(id: '', nombre: '', color: '#6b7280'),
          )
          .color;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Helpers.hexToColorFlutter(sColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          s,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      );
    }).toList();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Helpers.hexToColorFlutter(colorHex),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${grupo['tipoTela'] ?? 'Sin Tipo'} - ${grupo['color']}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${grupo['empresa']} • ${grupo['codigoColor']}",
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "${grupo['cantidad']}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Text(
                "${(grupo['metrajeTotal'] as double).toStringAsFixed(1)} m",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: badges.isEmpty
                    ? [
                        const Text(
                          "Sin asignar",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ]
                    : badges,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
