import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/providers/active_role_provider.dart';

class RoleSelector extends ConsumerWidget {
  const RoleSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesProvider);
    final activeId = ref.watch(activeRoleIdProvider);

    return rolesAsync.when(
      data: (roles) {
        if (roles.length <= 1)
          return const SizedBox(); // Si solo tiene 1 rol, no mostramos selector

        return Card(
          elevation: 2,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: activeId,
                hint: const Text("Seleccionar Rol"),
                items: roles.map((rol) {
                  return DropdownMenuItem(
                    value: rol.id,
                    child: Row(
                      children: [
                        const Icon(Icons.badge, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          rol.nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newId) {
                  if (newId != null) {
                    ref.read(activeRoleIdProvider.notifier).state = newId;
                  }
                },
              ),
            ),
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text("Error roles"),
    );
  }
}
