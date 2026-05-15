import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:inv_telas/models/lote.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/providers/lotes_providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/confirm_dialog.dart';
import 'lote_form_screen.dart';

class LotesScreen extends ConsumerWidget {
  const LotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lotesAsync = ref.watch(lotesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestión de Lotes"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: lotesAsync.when(
        data: (lotes) {
          if (lotes.isEmpty) {
            return const Center(child: Text("No hay lotes creados."));
          }
          // Ya viene ordenado por el servicio
          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: Web usa DataTable, Móvil usa ListView
              if (constraints.maxWidth > 600) {
                return _buildDataTable(context, ref, lotes);
              } else {
                return _buildMobileList(context, ref, lotes);
              }
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoteFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Vista Web
  Widget _buildDataTable(
    BuildContext context,
    WidgetRef ref,
    List<Lote> lotes,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        columns: const [
          DataColumn(label: Text("Nombre Lote")),
          DataColumn(label: Text("Fecha Creación")),
          DataColumn(label: Text("Estado/Activo")),
          DataColumn(label: Text("Acciones")),
        ],
        rows: lotes.map((lote) => _buildRow(context, ref, lote)).toList(),
      ),
    );
  }

  // Vista Móvil
  Widget _buildMobileList(
    BuildContext context,
    WidgetRef ref,
    List<Lote> lotes,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: lotes.length,
      itemBuilder: (context, index) =>
          _buildListTile(context, ref, lotes[index]),
    );
  }

  // Construcción de Fila/Tile compartido (lógica)
  DataRow _buildRow(BuildContext context, WidgetRef ref, Lote lote) {
    return DataRow(
      cells: [
        DataCell(Text(lote.nombre)),
        DataCell(Text(DateFormat('dd-MM-yyyy').format(lote.fechaCreacion))),
        DataCell(
          Checkbox(
            value: lote.activo,
            onChanged: (v) => _toggleActivo(ref, lote, v),
          ),
        ),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _goToEdit(context, lote),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteLote(context, ref, lote),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, WidgetRef ref, Lote lote) {
    return Card(
      child: ListTile(
        title: Text(lote.nombre),
        subtitle: Text(DateFormat('dd-MM-yyyy').format(lote.fechaCreacion)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: lote.activo,
              onChanged: (v) => _toggleActivo(ref, lote, v),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _goToEdit(context, lote),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteLote(context, ref, lote),
            ),
          ],
        ),
      ),
    );
  }

  // Acciones
  Future<void> _toggleActivo(WidgetRef ref, Lote lote, bool? value) async {
    if (value != null) {
      await ref.read(lotesServiceProvider).toggleActivo(lote.id, value);
    }
  }

  void _goToEdit(BuildContext context, Lote lote) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoteFormScreen(loteId: lote.id)),
    );
  }

  Future<void> _deleteLote(
    BuildContext context,
    WidgetRef ref,
    Lote lote,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ConfirmDialog(
        titulo: "¿Eliminar Lote?",
        mensaje: "Esta acción no se puede deshacer (eliminación lógica).",
        textoConfirmar: "Eliminar",
        isDanger: true,
      ),
    );

    if (confirm == true) {
      final user = ref.read(authProvider).value;
      if (user != null) {
        await ref.read(lotesServiceProvider).eliminarLote(lote.id, user.id);
      }
    }
  }
}
