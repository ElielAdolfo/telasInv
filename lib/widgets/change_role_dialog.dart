import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/empresa.dart';

class ChangeRoleDialog extends ConsumerWidget {
  const ChangeRoleDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    final empresas = session.empresasDisponibles;
    final empresaActual = session.empresaActual;
    final rolActual = session.rolActual;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

      title: Row(
        children: [
          Icon(Icons.business, color: Colors.blue[700]),
          const SizedBox(width: 10),

          const Text("Cambiar Empresa", style: TextStyle(fontSize: 18)),
        ],
      ),

      content: SizedBox(
        width: 350,

        child: empresas.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No tiene empresas asignadas'),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: empresas.length,

                itemBuilder: (context, index) {
                  final Empresa empresa = empresas[index];

                  final isSelected = empresa.id == empresaActual?.id;

                  return Card(
                    color: isSelected ? Colors.blue[50] : Colors.grey[50],

                    elevation: isSelected ? 2 : 0,

                    margin: const EdgeInsets.symmetric(vertical: 4),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),

                      side: BorderSide(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,

                        width: isSelected ? 1.5 : 0.5,
                      ),
                    ),

                    child: RadioListTile<String>(
                      value: empresa.id,

                      groupValue: empresaActual?.id,

                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            empresa.nombre,

                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,

                              color: isSelected
                                  ? Colors.blue[800]
                                  : Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            isSelected
                                ? 'Rol actual: ${rolActual?.nombre ?? "Sin rol"}'
                                : 'Cambiar a esta empresa',

                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),

                      secondary: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.blue[700],
                              size: 20,
                            )
                          : const Icon(Icons.business),

                      activeColor: Colors.blue[700],

                      onChanged: (String? value) async {
                        if (value == null) return;

                        final selectedEmpresa = empresas.firstWhere(
                          (e) => e.id == value,
                        );

                        /// CAMBIAR EMPRESA
                        await ref
                            .read(sessionProvider.notifier)
                            .cambiarEmpresa(selectedEmpresa);

                        if (context.mounted) {
                          Navigator.pop(context);

                          final newSession = ref.read(sessionProvider);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Empresa cambiada a '
                                '${selectedEmpresa.nombre}'
                                '\nRol: '
                                '${newSession.rolActual?.nombre ?? "Sin rol"}',
                              ),

                              backgroundColor: Colors.blue[700],

                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),

          child: const Text("Cerrar"),
        ),
      ],
    );
  }
}
