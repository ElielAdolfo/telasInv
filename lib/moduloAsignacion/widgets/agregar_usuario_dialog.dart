import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/providers/asignacion_provider.dart';

class AgregarUsuarioDialog extends ConsumerStatefulWidget {
  final Empresa empresa;

  const AgregarUsuarioDialog({super.key, required this.empresa});

  @override
  ConsumerState<AgregarUsuarioDialog> createState() =>
      _AgregarUsuarioDialogState();
}

class _AgregarUsuarioDialogState extends ConsumerState<AgregarUsuarioDialog> {
  final correoCtrl = TextEditingController();

  Usuario? usuarioEncontrado;

  bool buscando = false;
  bool guardando = false;

  @override
  void dispose() {
    correoCtrl.dispose();
    super.dispose();
  }

  Future<void> buscar() async {
    if (buscando) return;

    final correo = correoCtrl.text.trim();

    if (correo.isEmpty) {
      return;
    }

    setState(() {
      buscando = true;
      usuarioEncontrado = null;
    });

    try {
      final usuario = await ref
          .read(asignacionProvider)
          .buscarUsuarioPorCorreo(correo);

      if (!mounted) return;

      setState(() {
        usuarioEncontrado = usuario;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error buscando usuario: $e')));
    } finally {
      if (mounted) {
        setState(() {
          buscando = false;
        });
      }
    }
  }

  Future<void> agregar() async {
    if (guardando) return;

    if (usuarioEncontrado == null) {
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      await ref
          .read(asignacionProvider)
          .agregarUsuarioAEmpresa(
            empresa: widget.empresa,
            usuario: usuarioEncontrado!,
          );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error agregando usuario: $e')));
    } finally {
      if (mounted) {
        setState(() {
          guardando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Usuario'),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: correoCtrl,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                suffixIcon: buscando
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: buscar,
                      ),
              ),
              onSubmitted: (_) => buscar(),
            ),

            const SizedBox(height: 20),

            if (usuarioEncontrado != null)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(usuarioEncontrado!.nombre),
                  subtitle: Text(usuarioEncontrado!.email),
                ),
              ),

            if (!buscando &&
                correoCtrl.text.isNotEmpty &&
                usuarioEncontrado == null)
              const Text(
                'Usuario no encontrado',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: guardando
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: guardando || usuarioEncontrado == null ? null : agregar,
          child: guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Agregar'),
        ),
      ],
    );
  }
}
