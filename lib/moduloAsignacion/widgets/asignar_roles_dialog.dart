import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/usuario.dart';
import 'package:inv_telas/moduloAbms/roles/providers/rol_abm_provider.dart';
import 'package:inv_telas/providers/asignacion_provider.dart';
import 'package:inv_telas/providers/empresa_provider.dart';
import 'package:inv_telas/providers/usuario_provider.dart';

class AsignarRolesDialog extends ConsumerStatefulWidget {
  final Empresa empresa;
  final Usuario usuario;
  final String sucursalId;
  final String sucursalNombre;

  const AsignarRolesDialog({
    super.key,
    required this.empresa,
    required this.usuario,
    required this.sucursalId,
    required this.sucursalNombre,
  });

  @override
  ConsumerState<AsignarRolesDialog> createState() => _AsignarRolesDialogState();
}

class _AsignarRolesDialogState extends ConsumerState<AsignarRolesDialog> {
  final selectedRoles = <String>{};
  bool saving = false;

  // NUEVOS ESTADOS: Para controlar la carga inicial de la Base de Datos
  bool loadingInitialRoles = true;
  String? errorLoadingRoles;

  @override
  void initState() {
    super.initState();
    _cargarRolesRealesDesdeBD();
  }

  // MÉTODO ASÍNCRONO: Trae la información real del backend/BD
  Future<void> _cargarRolesRealesDesdeBD() async {
    try {
      // Explicación: Llamamos a la BD usando tu backend a través del provider
      final List<String> rolesReales = await ref
          .read(asignacionProvider)
          .obtenerRolesAsignados(
            empresaId: widget.empresa.id,
            usuarioId: widget.usuario.id,
            sucursalId: widget.sucursalId,
          );

      if (mounted) {
        setState(() {
          selectedRoles.clear();
          selectedRoles.addAll(rolesReales);
          loadingInitialRoles = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorLoadingRoles = 'No se pudieron obtener los roles actuales.';
          loadingInitialRoles = false;
        });
      }
      print('Error al cargar roles reales de la BD: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesAbmStreamProvider);
    final primaryPurple = const Color(0xFF5E4EAD);

    return AlertDialog(
      backgroundColor: const Color(0xFFF3EFF6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 12,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24,
        top: 16,
      ),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: primaryPurple, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${widget.empresa.nombre} - ${widget.sucursalNombre}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.usuario.nombre,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1, thickness: 1, color: Colors.black12),
          ),

          Row(
            children: [
              const Icon(Icons.security, color: Colors.black87, size: 22),
              const SizedBox(width: 10),
              const Text(
                'Asignar roles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),

      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDFE4F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade900,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    loadingInitialRoles
                        ? 'Cargando asignaciones...'
                        : '${selectedRoles.length} rol(es) seleccionados',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Control de renderizado jerárquico según el estado de la BD
            Flexible(
              child: loadingInitialRoles
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : errorLoadingRoles != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          errorLoadingRoles!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                  : rolesAsync.when(
                      data: (roles) {
                        if (roles.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text('No hay roles disponibles.'),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: roles.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final rol = roles[index];
                            final isSelected = selectedRoles.contains(rol.id);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE2DFE5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black12
                                      : Colors.transparent,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.black.withOpacity(0.06)
                                        : Colors.black.withOpacity(0.02),
                                    blurRadius: isSelected ? 6 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedRoles.remove(rol.id);
                                    } else {
                                      selectedRoles.add(rol.id);
                                    }
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: primaryPurple,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value == true) {
                                              selectedRoles.add(rol.id);
                                            } else {
                                              selectedRoles.remove(rol.id);
                                            }
                                          });
                                        },
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rol.nombre,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isSelected
                                                  ? 'Asignado'
                                                  : 'Sin asignar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: isSelected
                                                    ? const Color(0xFF2E7D32)
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('Error al cargar roles: $err'),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: primaryPurple,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          child: const Text(
            'Cancelar',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),

        ElevatedButton.icon(
          onPressed: (saving || loadingInitialRoles)
              ? null
              : () async {
                  setState(() => saving = true);
                  try {
                    // 1. Guardas los cambios en la base de datos
                    await ref
                        .read(asignacionProvider)
                        .asignarRoles(
                          empresa: widget.empresa,
                          usuario: widget.usuario,
                          sucursalId: widget.sucursalId,
                          rolesIds: selectedRoles.toList(),
                        );

                    // 2. REFRESCAR LOS DATOS REALES DE LA BD
                    // Forzamos la actualización del detalle de la empresa
                    ref.invalidate(empresaDetalleProvider(widget.empresa.id));

                    // Forzamos la actualización de la lista de usuarios permitidos vinculados a esta empresa
                    ref.invalidate(usuariosPermitidosProvider(widget.empresa));

                    if (mounted) Navigator.pop(context);
                  } catch (e) {
                    print("Error al guardar: $e");
                  } finally {
                    if (mounted) setState(() => saving = false);
                  }
                },
          style:
              ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                  states,
                ) {
                  if (states.contains(WidgetState.disabled)) {
                    return primaryPurple.withOpacity(0.5);
                  }
                  return primaryPurple;
                }),
              ),
          icon: saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(
            saving ? 'Guardando...' : 'Guardar cambios',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
        ),
      ],
    );
  }
}
