import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/providers/auth_provider.dart';
import 'package:inv_telas/providers/relaciones_provider.dart';
import 'package:inv_telas/providers/providers.dart'; // Asume que providers.dart expone sucursalesProvider
import 'package:inv_telas/models/catalogos.dart'; // Para Sucursal
import 'package:inv_telas/utils/utils.dart';

class RelacionesScreen extends ConsumerStatefulWidget {
  const RelacionesScreen({super.key});

  @override
  ConsumerState<RelacionesScreen> createState() => _RelacionesScreenState();
}

class _RelacionesScreenState extends ConsumerState<RelacionesScreen> {
  bool _isSaving = false;

  Future<void> _editarRelaciones(Usuario usuario) async {
    // Estados temporales para el diálogo
    Set<String> rolesSeleccionados = Set<String>.from(usuario.rolesIds);
    Set<String> sucursalesSeleccionadas = Set<String>.from(
      usuario.sucursalesIds,
    );

    final roles = await ref.read(relacionesServiceProvider).obtenerRoles();
    final sucursales = ref.read(
      sucursalesProvider,
    ); // Asume que existe este provider de providers.dart

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Asignar a: ${usuario.nombre}'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Roles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: roles
                          .map(
                            (rol) => FilterChip(
                              label: Text(rol.nombre),
                              selected: rolesSeleccionados.contains(rol.id),
                              onSelected: (bool selected) {
                                setDialogState(() {
                                  selected
                                      ? rolesSeleccionados.add(rol.id)
                                      : rolesSeleccionados.remove(rol.id);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Sucursales',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    sucursales.isEmpty
                        ? const Text('No hay sucursales configuradas')
                        : Wrap(
                            spacing: 8.0,
                            children: sucursales
                                .map(
                                  (s) => FilterChip(
                                    label: Text(s.nombre),
                                    selected: sucursalesSeleccionadas.contains(
                                      s.id,
                                    ),
                                    onSelected: (bool selected) {
                                      setDialogState(() {
                                        selected
                                            ? sucursalesSeleccionadas.add(s.id)
                                            : sucursalesSeleccionadas.remove(
                                                s.id,
                                              );
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: _isSaving
                    ? null
                    : () async {
                        setState(() => _isSaving = true);
                        setDialogState(() {}); // Refresca el botón del diálogo

                        try {
                          await ref
                              .read(relacionesServiceProvider)
                              .actualizarUsuarioRelaciones(
                                usuarioId: usuario.id,
                                rolesIds: rolesSeleccionados.toList(),
                                sucursalesIds: sucursalesSeleccionadas.toList(),
                              );

                          // Opcional: Invalidar provider de usuarios si tuviéramos una lista global
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Relaciones actualizadas'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al guardar: $e')),
                          );
                        } finally {
                          setState(() => _isSaving = false);
                        }
                      },
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nota: Para listar todos los usuarios, idealmente necesitaríamos un provider específico
    // Usaremos una consulta directa a Firebase aquí para el ejemplo,
    // asumiendo que no tienes un usuariosListProvider global en el código proporcionado.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relaciones Usuario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Usuario>>(
        future: ref
            .read(relacionesServiceProvider)
            .obtenerUsuarios(), // Método a agregar en service
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final usuarios = snapshot.data ?? [];

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, i) {
              final u = usuarios[i];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(u.nombre[0])),
                  title: Text(u.nombre),
                  subtitle: Text(
                    'Roles: ${u.rolesIds.length} | Sucursales: ${u.sucursalesIds.length}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _editarRelaciones(u),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
