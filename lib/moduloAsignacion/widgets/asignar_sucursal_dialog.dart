import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/models/sucursal.dart';

import 'package:inv_telas/providers/asignacion_provider.dart';
import 'package:inv_telas/providers/empresa_provider.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';

class AsignarSucursalDialog extends ConsumerStatefulWidget {
  final Empresa empresa;
  final Usuario usuario;

  const AsignarSucursalDialog({
    super.key,
    required this.empresa,
    required this.usuario,
  });

  @override
  ConsumerState<AsignarSucursalDialog> createState() =>
      _AsignarSucursalDialogState();
}

class _AsignarSucursalDialogState extends ConsumerState<AsignarSucursalDialog> {
  bool cargandoInicial = true;
  bool guardando = false;

  final Set<String> seleccionadas = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    try {
      final empresaActualizada = await ref.read(
        empresaDetalleProvider(widget.empresa.id).future,
      );

      if (empresaActualizada == null) {
        throw Exception('Empresa no encontrada');
      }

      print('======== DIALOG ========');
      print('usuario.id = ${widget.usuario.id}');

      for (final permiso in empresaActualizada.usuariosPermitidos) {
        print('permiso.usuarioId = ${permiso.usuarioId}');
      }

      final permiso = empresaActualizada.usuariosPermitidos.firstWhere(
        (e) => e.usuarioId == widget.usuario.id,
      );

      seleccionadas.clear();

      for (final sucursal in permiso.sucursales) {
        seleccionadas.add(sucursal.sucursalId);

        print('Sucursal cargada -> ${sucursal.sucursalId}');
      }
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
    } finally {
      if (mounted) {
        setState(() {
          cargandoInicial = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargandoInicial) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          content: SizedBox(
            width: 350,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Cargando información',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Obteniendo sucursales asignadas...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final sucursalesAsync = ref.watch(sucursalesProvider(widget.empresa.id));

    return PopScope(
      canPop: !guardando,
      child: AlertDialog(
        insetPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            const Icon(Icons.store),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Asignar sucursales',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),

        content: SizedBox(
          width: 700,
          height: 520,
          child: sucursalesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),

            error: (e, _) => Center(
              child: Text(
                'Error cargando sucursales\n$e',
                textAlign: TextAlign.center,
              ),
            ),

            data: (sucursales) {
              if (sucursales.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 70, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No existen sucursales registradas'),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${seleccionadas.length} sucursal(es) seleccionadas',
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: sucursales.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, index) {
                        final sucursal = sucursales[index];

                        return _SucursalCheckboxCard(
                          sucursal: sucursal,
                          checked: seleccionadas.contains(sucursal.id),
                          enabled: !guardando,
                          onChanged: (value) {
                            setState(() {
                              if (value) {
                                seleccionadas.add(sucursal.id);
                              } else {
                                seleccionadas.remove(sucursal.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        actions: [
          TextButton(
            onPressed: guardando
                ? null
                : () {
                    Navigator.of(context).pop(false);
                  },
            child: const Text('Cancelar'),
          ),

          FilledButton.icon(
            icon: guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),

            label: Text(guardando ? 'Guardando...' : 'Guardar cambios'),

            onPressed: guardando
                ? null
                : () async {
                    if (seleccionadas.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Debe seleccionar al menos una sucursal',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      guardando = true;
                    });

                    try {
                      await ref
                          .read(asignacionProvider)
                          .sincronizarSucursalesUsuario(
                            empresaId: widget.empresa.id,
                            usuarioId: widget.usuario.id,
                            sucursalesSeleccionadas: seleccionadas.toList(),
                          );

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sucursales actualizadas correctamente',
                          ),
                        ),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    } finally {
                      if (mounted) {
                        setState(() {
                          guardando = false;
                        });
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }
}

class _SucursalCheckboxCard extends StatelessWidget {
  final Sucursal sucursal;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SucursalCheckboxCard({
    required this.sucursal,
    required this.checked,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: checked ? 4 : 1,
      color: checked ? Colors.green.withOpacity(0.08) : null,
      child: CheckboxListTile(
        value: checked,
        controlAffinity: ListTileControlAffinity.leading,

        title: Text(
          sucursal.nombre,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),

        subtitle: Text(sucursal.direccion ?? ''),

        onChanged: enabled ? (v) => onChanged(v ?? false) : null,
      ),
    );
  }
}
