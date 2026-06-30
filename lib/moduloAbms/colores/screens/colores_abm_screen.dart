import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
// Si usas ConfirmActionDialog cámbialo aquí
// O el proveedor de sesión correspondiente
import '../../../providers/color_provider.dart';
import '../../../models/abmTiposTelas/color_tela.dart';
import '../widgets/color_table.dart';
import '../widgets/color_form_dialog.dart';

class ColoresAbmScreen extends ConsumerWidget {
  const ColoresAbmScreen({super.key});

  void _abrirFormularioModal(
    BuildContext context,
    String empresaId,
    String usuarioId, {
    ColorTela? colorItem,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // OBLIGATORIO: No se cierra al presionar la zona negra exterior
      builder: (context) => ColorFormDialog(
        empresaId: empresaId,
        usuarioId: usuarioId,
        colorAEditar: colorItem,
      ),
    );
  }

  void _confirmarBajaLogica(
    BuildContext context,
    WidgetRef ref,
    String empresaId,
    String usuarioId,
    ColorTela colorItem,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se cierra en zona negra
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('¿Eliminar Color?'),
          ],
        ),
        content: Text(
          '¿Está seguro de eliminar el color "${colorItem.nombre}"? Esta acción se aplicará como una baja lógica.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(context).pop(); // Cerramos diálogo de confirmación
              await ref
                  .read(coloresProvider(empresaId).notifier)
                  .eliminarColor(colorItem.id, usuarioId);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos los datos de la sesión actual de tus proveedores estructurales
    // Nota: Ajusta estas llamadas según el nombre exacto de tus campos de estado (Ej: authState, sessionState)
    final session = ref.watch(sessionProvider);

    final empresa = session.empresaActual;

    if (empresa == null) {
      return const Scaffold(
        body: Center(child: Text('Debe seleccionar una empresa')),
      );
    }

    final empresaIdActual = empresa.id;

    final usuarioIdActual = session.usuario?.id ?? '';

    final coloresAsync = ref.watch(coloresProvider(empresaIdActual));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo ABM de Colores'),
        backgroundColor: Colors.indigo.shade50,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Agregar Color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _abrirFormularioModal(
                context,
                empresaIdActual,
                usuarioIdActual,
              ),
            ),
          ),
        ],
      ),
      body: coloresAsync.when(
        data: (listaDeColores) {
          return SingleChildScrollView(
            child: Column(
              children: [
                ColorTable(
                  colores: listaDeColores,
                  onEdit: (color) => _abrirFormularioModal(
                    context,
                    empresaIdActual,
                    usuarioIdActual,
                    colorItem: color,
                  ),
                  onDelete: (color) => _confirmarBajaLogica(
                    context,
                    ref,
                    empresaIdActual,
                    usuarioIdActual,
                    color,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(64.0),
            child: CircularProgressIndicator(color: Colors.indigo),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Error al cargar la base de datos de colores: $error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
