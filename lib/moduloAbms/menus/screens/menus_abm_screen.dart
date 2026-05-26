import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/widgets/action_dialog.dart';
import 'package:inv_telas/models/menu_item.dart';
import 'package:inv_telas/moduloAbms/menus/providers/menu_abm_provider.dart';
import 'package:inv_telas/moduloAbms/menus/widgets/menu_form_dialog.dart';
import 'package:inv_telas/utils/icon_mapper.dart';

class MenusAbmScreen extends ConsumerWidget {
  const MenusAbmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menusAsync = ref.watch(menusAbmStreamProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const MenuFormDialog(menu: null),
          );
        },
        label: const Text('Nuevo Menú'),
        icon: const Icon(Icons.add),
      ),
      body: menusAsync.when(
        data: (menus) {
          if (menus.isEmpty) return const Center(child: Text('No hay menús'));

          // RESPONSIVE: Tarjetas en Móvil, Tabla en PC
          if (isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: menus.length,
              itemBuilder: (_, i) => _MenuCard(menu: menus[i]),
            );
          } else {
            return _MenuTable(menus: menus);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

// Widget para Vista de Tabla (PC)
class _MenuTable extends StatelessWidget {
  final List<MenuApp> menus;
  const _MenuTable({required this.menus});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Ruta')),
          DataColumn(label: Text('Icono')),
          DataColumn(label: Text('Orden')),
          DataColumn(label: Text('Activo')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: menus.map((m) {
          return DataRow(
            cells: [
              DataCell(Text(m.nombre)),
              DataCell(Text(m.ruta)),
              DataCell(Icon(IconMapper.getIcon(m.icono))),
              DataCell(Text(m.ordenBase.toString())),
              DataCell(
                Icon(
                  m.activo ? Icons.check_circle : Icons.cancel,
                  color: m.activo ? Colors.green : Colors.red,
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(context, m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(context, m),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Widget para Vista de Tarjeta (Móvil)
class _MenuCard extends StatelessWidget {
  final MenuApp menu;
  const _MenuCard({required this.menu});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(IconMapper.getIcon(menu.icono)),
        title: Text(menu.nombre),
        subtitle: Text(menu.ruta),
        trailing: PopupMenuButton(
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
          onSelected: (val) {
            if (val == 'edit') _openForm(context, menu);
            if (val == 'delete') _confirmDelete(context, menu);
          },
        ),
      ),
    );
  }
}

void _openForm(BuildContext context, MenuApp? menu) {
  showDialog(
    context: context,
    builder: (_) => MenuFormDialog(menu: menu),
  );
}

void _confirmDelete(BuildContext context, MenuApp menu) {
  showDialog(
    context: context,
    builder: (_) => ActionDialog(
      titulo: 'Eliminar Menú',
      mensaje: '¿Está seguro de eliminar el menú "${menu.nombre}"?',
      type: ActionDialogType.delete,
      onConfirm: () async {
        // Aquí necesitarías inyectar el ref o pasar el service, simplificamos usando ProviderScope
        final container = ProviderScope.containerOf(context);
        await container.read(menuAbmServiceProvider).eliminarMenu(menu.id);
      },
    ),
  );
}
