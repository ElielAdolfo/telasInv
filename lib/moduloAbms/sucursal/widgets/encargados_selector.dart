import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/providers/usuario_provider.dart';

class EncargadosSelector extends ConsumerStatefulWidget {
  final Empresa? empresa;

  final List<String> selectedIds;

  final Function(List<String>) onChanged;

  const EncargadosSelector({
    super.key,
    required this.empresa,
    required this.selectedIds,
    required this.onChanged,
  });

  @override
  ConsumerState<EncargadosSelector> createState() => _EncargadosSelectorState();
}

class _EncargadosSelectorState extends ConsumerState<EncargadosSelector> {
  late List<String> selectedIds;

  @override
  void initState() {
    super.initState();

    selectedIds = [...widget.selectedIds];
  }

  @override
  void didUpdateWidget(covariant EncargadosSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// si cambia empresa
    if (oldWidget.empresa?.id != widget.empresa?.id) {
      setState(() {
        selectedIds = [];
      });

      widget.onChanged([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final empresa = widget.empresa;

    if (empresa == null) {
      return _emptyCard('Seleccione una empresa para cargar usuarios');
    }

    final usuariosAsync = ref.watch(usuariosEmpresaProvider(empresa.id));

    return usuariosAsync.when(
      data: (usuarios) {
        if (usuarios.isEmpty) {
          return _emptyCard('No hay usuarios registrados en esta empresa');
        }

        return Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(14),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Row(
                children: [
                  Icon(Icons.manage_accounts),

                  SizedBox(width: 8),

                  Text(
                    'Encargados',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                'Los encargados tendrán control total de esta sucursal.',
                style: TextStyle(color: Colors.grey.shade700),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: usuarios.map((usuario) {
                  final selected = selectedIds.contains(usuario.id);

                  return FilterChip(
                    selected: selected,

                    avatar: CircleAvatar(
                      child: Text(
                        usuario.nombre.isNotEmpty
                            ? usuario.nombre[0].toUpperCase()
                            : '?',
                      ),
                    ),

                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(usuario.nombre),

                        Text(
                          usuario.email,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),

                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          selectedIds.remove(usuario.id);
                        } else {
                          selectedIds.add(usuario.id);
                        }
                      });

                      widget.onChanged(selectedIds);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },

      loading: () => Container(
        padding: const EdgeInsets.all(20),

        child: const Center(child: CircularProgressIndicator()),
      ),

      error: (e, _) => _emptyCard('Error cargando usuarios\n$e'),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
}
