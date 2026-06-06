import 'package:flutter/material.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/models/sucursal.dart';

class SucursalRolesCard extends StatelessWidget {
  final Sucursal sucursal;
  final List<Rol> roles;
  final VoidCallback? onEditarRoles;

  const SucursalRolesCard({
    super.key,
    required this.sucursal,
    required this.roles,
    this.onEditarRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.store),
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    sucursal.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),

                if (onEditarRoles != null)
                  IconButton(
                    onPressed: onEditarRoles,
                    icon: const Icon(Icons.edit),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            if (roles.isEmpty)
              const Text(
                'Sin roles asignados',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: roles
                    .map(
                      (rol) => Chip(
                        label: Text(rol.nombre),
                        avatar: const Icon(Icons.security, size: 16),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
