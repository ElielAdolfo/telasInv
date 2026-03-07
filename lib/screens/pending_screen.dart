import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/constants.dart';
import 'package:inv_telas/widgets/confirm_dialog.dart';

class PendingScreen extends ConsumerStatefulWidget {
  const PendingScreen({super.key});

  @override
  ConsumerState<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends ConsumerState<PendingScreen> {
  bool _isUploading = false;
  String _progressText = '';
  int _currentUploadIndex = 0;
  int _totalToUpload = 0;

  Future<void> _uploadBatch() async {
    final confirm = await ConfirmDialog.show(
      context: context,
      titulo: '¿Subir Lote Completo?',
      mensaje: 'Se subirán todos los rollos pendientes a Firebase.',
      textoConfirmar: 'Subir Todo',
    );
    if (confirm != true) return;

    setState(() {
      _isUploading = true;
      _currentUploadIndex = 0;
    });

    final drafts = ref.read(draftsProvider);
    _totalToUpload = drafts.length;

    // Iteramos uno por uno para dar feedback
    for (var i = 0; i < drafts.length; i++) {
      // Verificamos si el widget sigue montado (por si el usuario cierra)
      if (!mounted) return;

      final rollo = drafts[i];

      setState(() {
        _currentUploadIndex = i + 1;
        _progressText = 'Subiendo $_currentUploadIndex de $_totalToUpload...';
      });

      try {
        // 1. Intentar subir a Firebase
        await ref.read(rolloServiceProvider).createRollo(rollo);

        // 2. Si tuvo éxito, borrar de local
        await ref.read(draftsProvider.notifier).remove(rollo.id);
      } catch (e) {
        // Si falla, nos detenemos o continuamos.
        // Aquí decidimos detenernos para que el usuario vea el error.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en ${rollo.codigoColor}: $e')),
          );
        }
        break;
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        _progressText = 'Proceso finalizado';
      });

      // Si todo salió bien, mostramos mensaje final
      if (ref.read(draftsProvider).isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todos los datos fueron subidos correctamente'),
          ),
        );
      }
    }
  }

  Future<void> _clearAll() async {
    final confirm = await ConfirmDialog.show(
      context: context,
      titulo: '¿Limpiar Pendientes?',
      mensaje: 'Se eliminarán TODOS los datos locales sin subirlos a Firebase.',
      textoConfirmar: 'Limpiar Todo',
      isDanger: true,
    );
    if (confirm == true) {
      await ref.read(draftsProvider.notifier).clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final drafts = ref.watch(draftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rollos Pendientes de Subir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: drafts.isEmpty || _isUploading ? null : _clearAll,
            tooltip: 'Limpiar Todo',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isUploading)
            Container(
              color: AppColors.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Text(_progressText, style: AppTextStyles.heading3),
                ],
              ),
            ),

          Expanded(
            child: drafts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_done,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No hay datos pendientes',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: drafts.length,
                    itemBuilder: (context, index) {
                      final rollo = drafts[index];
                      return ListTile(
                        leading: const Icon(Icons.inventory_2),
                        title: Text('Rollo: ${rollo.codigoColor}'),
                        subtitle: Text('Metraje: ${rollo.metraje}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: _isUploading
                              ? null
                              : () => _deleteSingleDraft(rollo.id),
                        ),
                      );
                    },
                  ),
          ),
          if (drafts.isNotEmpty && !_isUploading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _uploadBatch,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("SUBIR TODO A FIREBASE"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteSingleDraft(String id) async {
    final confirm = await ConfirmDialog.show(
      context: context,
      titulo: '¿Eliminar este borrador?',
      mensaje: 'Este dato se perderá y no se subirá a la nube.',
      isDanger: true,
    );
    if (confirm == true) {
      await ref.read(draftsProvider.notifier).remove(id);
    }
  }
}
