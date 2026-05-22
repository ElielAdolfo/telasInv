import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/models/rol.dart';
import 'package:inv_telas/moduloConfiguracion/widgets/menu_form_dialog.dart';
import 'package:inv_telas/moduloConfiguracion/widgets/rol_form_dialog.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/confirm_dialog.dart';
import 'package:inv_telas/widgets/loading_overlay.dart';
import '../providers/configuracion_provider.dart';

class ConfiguracionScreen extends ConsumerStatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  ConsumerState<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends ConsumerState<ConfiguracionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Módulo de Configuración"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.menu), text: "Menús"),
            Tab(icon: Icon(Icons.security), text: "Roles"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_MenusTab(), _RolesTab()],
      ),
    );
  }
}

// =================== TAB MENÚS ===================

class _MenusTab extends ConsumerWidget {
  const _MenusTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(menusAdminProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const MenuFormDialog(menu: null),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: menusAsync.when(
        data: (menus) {
          if (menus.isEmpty)
            return const Center(child: Text("No hay menús creados."));
          return ListView.builder(
            itemCount: menus.length,
            itemBuilder: (_, i) => _MenuTile(menu: menus[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _MenuTile extends ConsumerWidget {
  final MenuApp menu;
  const _MenuTile({required this.menu});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        IconMapper.getIcon(menu.icono),
      ), // Asumiendo que tienes IconMapper
      title: Text(menu.nombre),
      subtitle: Text("Ruta: ${menu.ruta}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: menu.activo,
            onChanged: (v) async {
              final newMenu = menu.copyWith(activo: v);
              await ref.read(menuAdminServiceProvider).saveMenu(newMenu);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => MenuFormDialog(menu: menu),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDialog(
                  titulo: "Eliminar Menú",
                  mensaje: "¿Seguro de eliminar lógicamente este menú?",
                  isDanger: true,
                ),
              );
              if (confirm == true) {
                await ref
                    .read(menuAdminServiceProvider)
                    .deleteMenuLogic(menu.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

// =================== TAB ROLES ===================

class _RolesTab extends ConsumerWidget {
  const _RolesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(rolesAdminProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const RolFormDialog(rol: null),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: rolesAsync.when(
        data: (roles) {
          if (roles.isEmpty)
            return const Center(child: Text("No hay roles creados."));
          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (_, i) => _RolTile(rol: roles[i]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
    );
  }
}

class _RolTile extends ConsumerWidget {
  final Rol rol;
  const _RolTile({required this.rol});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(Icons.badge),
      title: Text(rol.nombre),
      subtitle: Text("Permisos: ${rol.menusPermitidos.length} menús"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: rol.activo,
            onChanged: (v) async {
              final newRol = Rol(
                id: rol.id,
                nombre: rol.nombre,
                activo: v,
                menusPermitidos: rol.menusPermitidos,
                eliminado: rol.eliminado,
              );
              await ref.read(rolAdminServiceProvider).saveRol(newRol);
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => RolFormDialog(rol: rol),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => const ConfirmDialog(
                  titulo: "Eliminar Rol",
                  mensaje: "¿Seguro de eliminar lógicamente este rol?",
                  isDanger: true,
                ),
              );
              if (confirm == true) {
                await ref.read(rolAdminServiceProvider).deleteRolLogic(rol.id);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Helper para no romper si falta IconMapper (asumiendo que existe en tu proyecto)
class IconMapper {
  static IconData getIcon(String name) {
    // Implementación simple para no fallar, usa tu utils/icon_mapper.dart real
    return Icons.widgets;
  }
}
