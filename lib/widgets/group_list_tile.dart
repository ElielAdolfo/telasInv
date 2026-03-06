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
    final empresas = ref.watch(empresasProvider);
    final tipos = ref.watch(tiposTelaProvider);
    final colorId = grupo['colorId'] as String;
    final colorObj = colores.firstWhere(
      (c) => c.id == colorId,
      orElse: () => ColorTela(id: '', nombre: 'Sin Color', hex: '#94a3b8'),
    );
    final colorNombre = colorObj.nombre;
    final colorHex = colorObj.hex;

    // 2. Resolver Empresa
    final empresaId = grupo['empresaId'] as String;
    final empresaNombre = empresas
        .firstWhere(
          (e) => e.id == empresaId,
          orElse: () => Empresa(id: '', nombre: 'Sin Empresa'),
        )
        .nombre;

    // 3. Resolver Tipo Tela
    final tipoId = grupo['tipoTelaId'] as String;
    final tipoNombre = tipos
        .firstWhere(
          (t) => t.id == tipoId,
          orElse: () => TipoTela(id: '', nombre: 'Sin Tipo'),
        )
        .nombre;

    // 4. Resolver Badges de Sucursales
    final sucursalIds = grupo['sucursalIds'] as List;
    final badges = sucursalIds.map((sId) {
      final sObj = sucursales.firstWhere(
        (su) => su.id == sId,
        orElse: () => Sucursal(id: '', nombre: 'Desconocida', color: '#6b7280'),
      );
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Helpers.hexToColorFlutter(sObj.color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          sObj.nombre, // Mostramos el nombre
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
                    "$tipoNombre - $colorNombre",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "$empresaNombre • ${grupo['codigoColor']}",
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
