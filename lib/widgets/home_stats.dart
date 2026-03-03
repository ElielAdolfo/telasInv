import 'package:flutter/material.dart';
import 'package:inv_telas/widgets/stat_card.dart';

class HomeStats extends StatelessWidget {
  final Map<String, dynamic> stats;

  const HomeStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 1100
            ? 5
            : (constraints.maxWidth > 600 ? 3 : 2);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            StatCard(
              title: "Total Rollos",
              value: "${stats['totalRollos']}",
              icon: Icons.inventory_2,
              color: Colors.blue,
            ),
            StatCard(
              title: "Metraje Total",
              value: "${stats['metrajeTotal'].toStringAsFixed(1)} m",
              icon: Icons.straighten,
              color: Colors.green,
            ),
            StatCard(
              title: "Empresas",
              value: "${stats['empresas']}",
              icon: Icons.business,
              color: Colors.purple,
            ),
            StatCard(
              title: "Sucursales",
              value: "${stats['sucursales']}",
              icon: Icons.store,
              color: Colors.cyan,
            ),
            StatCard(
              title: "Colores",
              value: "${stats['colores']}",
              icon: Icons.palette,
              color: Colors.amber,
            ),
          ],
        );
      },
    );
  }
}
