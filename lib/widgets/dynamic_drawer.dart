import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/providers/active_role_provider.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/utils/icon_mapper.dart';
import 'package:inv_telas/widgets/role_selector.dart';

class DynamicDrawer extends ConsumerWidget {
  final List<MenuApp> menus;

  const DynamicDrawer({super.key, required this.menus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowedIds = ref.watch(allowedMenuIdsProvider);

    final user = ref.watch(authProvider).value;

    // ✅ MENUS FILTRADOS
    final filteredMenus = menus
        .where((m) => allowedIds.contains(m.id))
        .toList();

    // =========================
    // DEBUG CONSOLA
    // =========================

    print("=================================");
    print("👤 USUARIO: ${user?.nombre}");
    print("📧 EMAIL: ${user?.email}");

    print("🪪 ROLES IDS:");
    print(user?.rolesIds);

    print("✅ MENUS PERMITIDOS IDS:");
    print(allowedIds);

    print("📦 TODOS LOS MENUS:");
    for (final m in menus) {
      print(" - ${m.id} | ${m.nombre}");
    }

    print("🎯 MENUS FILTRADOS:");
    for (final m in filteredMenus) {
      print(" ✔ ${m.id} | ${m.nombre}");
    }

    print("=================================");

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.nombre ?? "Usuario"),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              child: Text(user?.nombre[0] ?? "U"),
            ),
          ),

          const RoleSelector(),

          const Divider(),

          Expanded(
            child: filteredMenus.isEmpty
                ? const Center(child: Text("Sin accesos para este rol"))
                : ListView.builder(
                    itemCount: filteredMenus.length,
                    itemBuilder: (context, index) {
                      final menu = filteredMenus[index];

                      return ListTile(
                        leading: Icon(IconMapper.getIcon(menu.icono)),
                        title: Text(menu.nombre),
                        onTap: () {
                          Navigator.pop(context);

                          print("🚀 Navegando a: ${menu.ruta}");
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
