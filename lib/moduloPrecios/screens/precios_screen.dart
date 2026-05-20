import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/catalogos.dart';
import 'package:inv_telas/models/precio_venta.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/confirm_dialog.dart';
import '../providers/precio_provider.dart';
import 'precio_form_screen.dart';

class PreciosScreen extends ConsumerStatefulWidget {
  const PreciosScreen({super.key});

  @override
  ConsumerState<PreciosScreen> createState() => _PreciosScreenState();
}

class _PreciosScreenState extends ConsumerState<PreciosScreen> {
  String? _selectedSucursalId;
  String? _selectedEmpresaId;

  @override
  Widget build(BuildContext context) {
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);

    // Watch al provider familiar solo si hay sucursal seleccionada
    final preciosAsync = ref.watch(todosLosPreciosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Módulo de Precios"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSucursalId,
                    hint: const Text("Seleccione Sucursal"),
                    items: sucursales
                        .map(
                          (s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedSucursalId = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedEmpresaId,
                    hint: const Text("Filtrar por Empresa (Opcional)"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Todas / General"),
                      ),
                      ...empresas.map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedEmpresaId = v),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Lista
          Expanded(
            child: preciosAsync.when(
              data: (lista) {
                // FILTRO SUCURSAL
                if (_selectedSucursalId != null) {
                  lista = lista
                      .where((p) => p.sucursalId == _selectedSucursalId)
                      .toList();
                }

                // FILTRO EMPRESA
                if (_selectedEmpresaId != null &&
                    _selectedEmpresaId!.isNotEmpty) {
                  lista = lista.where((p) {
                    return p.empresaId == _selectedEmpresaId ||
                        p.empresaId == null;
                  }).toList();
                }

                if (lista.isEmpty) {
                  return const Center(
                    child: Text("No hay precios configurados."),
                  );
                }

                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (ctx, i) {
                    final p = lista[i];

                    final sucursal = sucursales.firstWhere(
                      (s) => s.id == p.sucursalId,
                      orElse: () => Sucursal(id: '', nombre: 'Sucursal'),
                    );

                    final tiposTela = ref.watch(tiposTelaProvider);

                    final tela = tiposTela.firstWhere(
                      (t) => t.id == p.telaId,
                      orElse: () =>
                          TipoTela(id: p.telaId, nombre: 'Tela no encontrada'),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        title: Text(tela.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sucursal: ${sucursal.nombre}"),
                            Text("Precio Metro: ${p.precioMetro} Bs"),

                            if (p.tienePrecioMayor)
                              Text("Mayor: ${p.precioMayor} Bs"),

                            if (p.tienePrecioRollo)
                              Text(
                                p.tipoPrecioRollo == 'fijo'
                                    ? "Rollo fijo: ${p.precioRolloFijo}"
                                    : "Rollo dinámico: ${p.precioMetroRollo}",
                              ),
                          ],
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _goForm(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _delete(p),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },

              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goFormNew,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _goFormNew() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrecioFormScreen()),
    );
  }

  void _goForm(PrecioVenta p) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PrecioFormScreen(precioExistente: p)),
    );

    if (result == true) {
      ref.refresh(todosLosPreciosProvider);
    }
  }

  Future<void> _delete(PrecioVenta p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        titulo: "Eliminar Precio",
        mensaje: "¿Está seguro?",
        isDanger: true,
      ),
    );

    if (confirm == true && mounted) {
      final user = ref.read(authProvider).value;
      if (user != null) {
        try {
          await ref
              .read(preciosPorSucursalProvider(_selectedSucursalId!).notifier)
              .eliminar(p.id, user);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Precio eliminado")));
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      }
    }
  }
}
