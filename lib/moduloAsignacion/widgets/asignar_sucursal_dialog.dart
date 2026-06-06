import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/providers/asignacion_provider.dart';
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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final sucursalesAsync = ref.watch(
      sucursalesStreamProvider(widget.empresa.id),
    );

    return AlertDialog(
      title: const Text("Asignar sucursal"),
      content: SizedBox(
        width: 500,
        child: sucursalesAsync.when(
          data: (sucursales) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: sucursales.length,
              itemBuilder: (_, index) {
                final sucursal = sucursales[index];

                return ListTile(
                  title: Text(sucursal.nombre),
                  onTap: loading
                      ? null
                      : () async {
                          setState(() {
                            loading = true;
                          });

                          try {
                            await ref
                                .read(asignacionProvider)
                                .asignarSucursal(
                                  empresa: widget.empresa,
                                  usuario: widget.usuario,
                                  sucursalId: sucursal.id,
                                );

                            if (mounted) {
                              Navigator.pop(context);
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                loading = false;
                              });
                            }
                          }
                        },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
      ),
    );
  }
}
