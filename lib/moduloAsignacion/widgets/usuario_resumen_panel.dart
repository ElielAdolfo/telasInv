import 'package:flutter/material.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';

class UsuarioResumenPanel extends StatelessWidget {
  final Empresa empresa;
  final Usuario usuario;

  final VoidCallback? onAsignarSucursal;
  final VoidCallback? onDesactivar;

  const UsuarioResumenPanel({
    super.key,
    required this.empresa,
    required this.usuario,
    this.onAsignarSucursal,
    this.onDesactivar,
  });

  @override
  Widget build(BuildContext context) {
    final permiso = empresa.usuariosPermitidos.firstWhere(
      (e) => e.usuarioId == usuario.id,
    );

    final sucursalesActivas = permiso.sucursales
        .where((e) => e.activo && !e.eliminado)
        .toList();

    final totalRoles = permiso.sucursales
        .expand((e) => e.rolesIds)
        .toSet()
        .length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              child: Text(
                usuario.nombre.isNotEmpty
                    ? usuario.nombre[0].toUpperCase()
                    : '?',
              ),
            ),

            const SizedBox(height: 12),

            Text(
              usuario.nombre,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(usuario.email, style: const TextStyle(color: Colors.grey)),

            const Divider(height: 30),

            Row(
              children: [
                Expanded(
                  child: _InfoBox(
                    icon: Icons.store,
                    label: 'Sucursales',
                    value: sucursalesActivas.length.toString(),
                  ),
                ),

                Expanded(
                  child: _InfoBox(
                    icon: Icons.security,
                    label: 'Roles',
                    value: totalRoles.toString(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onAsignarSucursal,
                    icon: const Icon(Icons.add_business),
                    label: const Text('Sucursal'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: onDesactivar,
                    icon: const Icon(Icons.block),
                    label: const Text('Desactivar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon),

          const SizedBox(height: 8),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
