// archivo: widgets/proveedores_selector_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/session_provider.dart';
import '../../../providers/proveedores_provider.dart';
import '../../../widgets/confirm_action_dialog.dart';

// ==============================================================================
// 1. EL PICKER DIALOG PRINCIPAL (Lista y Selección)
// ==============================================================================
class ProveedoresSelectorDialog extends ConsumerStatefulWidget {
  final String empresaId;
  // Si ya hay un proveedor seleccionado en la variante, lo marcamos en la lista
  final String? proveedorIdInicial;

  const ProveedoresSelectorDialog({
    super.key,
    required this.empresaId,
    this.proveedorIdInicial,
  });

  @override
  ConsumerState<ProveedoresSelectorDialog> createState() =>
      _ProveedoresSelectorDialogState();
}

class _ProveedoresSelectorDialogState
    extends ConsumerState<ProveedoresSelectorDialog> {
  final buscarCtrl = TextEditingController();
  String filtro = '';
  String? proveedorIdSeleccionado;

  @override
  void initState() {
    super.initState();
    proveedorIdSeleccionado = widget.proveedorIdInicial;
    buscarCtrl.addListener(() {
      setState(() {
        filtro = buscarCtrl.text.trim().toUpperCase();
      });
    });
  }

  @override
  void dispose() {
    buscarCtrl.dispose();
    super.dispose();
  }

  void _abrirFormularioProveedor({Proveedor? proveedorAEditar}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Forzar uso de botones cancelar/guardar
      builder: (_) => ProveedorFormDialog(
        empresaId: widget.empresaId,
        proveedor: proveedorAEditar,
      ),
    );
    // Nota: Como usamos StreamProvider abajo, no necesitamos hacer nada al volver del diálogo,
    // la lista se actualizará sola si hubo cambios en Firebase.
  }

  @override
  Widget build(BuildContext context) {
    // Usamos StreamProvider para ver reflejados los cambios inmediatamente al añadir/editar
    final proveedoresStream = ref.watch(
      proveedoresStreamProvider(widget.empresaId),
    );

    return AlertDialog(
      title: const Text('Seleccionar Proveedor'),
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      content: SizedBox(
        width: 600,
        height: 700,
        child: Column(
          children: [
            // Barra de búsqueda y botón añadir
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: buscarCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Buscar proveedor (MAYÚSCULAS)...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _abrirFormularioProveedor(), // Crear nuevo
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Lista de proveedores
            Expanded(
              child: proveedoresStream.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e')),
                data: (todosLosProveedores) {
                  // Aplicar filtro de búsqueda
                  final proveedoresFiltrados = todosLosProveedores
                      .where((p) => p.nombre.contains(filtro))
                      .toList();

                  if (todosLosProveedores.isEmpty) {
                    return const Center(
                      child: Text('No hay proveedores registrados.'),
                    );
                  }

                  if (proveedoresFiltrados.isEmpty) {
                    return const Center(child: Text('No hay coincidencias.'));
                  }

                  return ListView.separated(
                    itemCount: proveedoresFiltrados.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final proveedor = proveedoresFiltrados[index];
                      final esSeleccionado =
                          proveedor.id == proveedorIdSeleccionado;

                      return ListTile(
                        selected: esSeleccionado,
                        selectedColor: Theme.of(context).primaryColor,
                        leading: CircleAvatar(
                          backgroundColor: esSeleccionado
                              ? Theme.of(context).primaryColor
                              : Colors.grey[200],
                          foregroundColor: esSeleccionado
                              ? Colors.white
                              : Colors.black87,
                          child: Text(proveedor.nombre[0]),
                        ),
                        title: Text(
                          proveedor.nombre,
                          style: TextStyle(
                            fontWeight: esSeleccionado
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            proveedorIdSeleccionado = proveedor.id;
                          });
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón Editar
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.blue,
                              ),
                              onPressed: () => _abrirFormularioProveedor(
                                proveedorAEditar: proveedor,
                              ),
                            ),
                            // Check de selección
                            if (esSeleccionado)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: proveedorIdSeleccionado == null
              ? null // Deshabilitado si no hay selección
              : () {
                  // Buscamos el objeto completo para devolverlo
                  final listaActual = proveedoresStream.value ?? [];
                  final proveedorFinal = listaActual.firstWhere(
                    (p) => p.id == proveedorIdSeleccionado,
                  );
                  Navigator.pop(context, proveedorFinal);
                },
          child: const Text('Seleccionar'),
        ),
      ],
    );
  }
}

// ==============================================================================
// 2. EL SUB-FORMULARIO DIALOG (Añadir/Editar - Aquí está la lógica de mayúsculas y duplicados)
// ==============================================================================
class ProveedorFormDialog extends ConsumerStatefulWidget {
  final String empresaId;
  final Proveedor? proveedor; // Null para crear, poblado para editar

  const ProveedorFormDialog({
    super.key,
    required this.empresaId,
    this.proveedor,
  });

  @override
  ConsumerState<ProveedorFormDialog> createState() =>
      _ProveedorFormDialogState();
}

class _ProveedorFormDialogState extends ConsumerState<ProveedorFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  bool _validandoDuplicado = false;

  @override
  void initState() {
    super.initState();
    if (widget.proveedor != null) {
      nombreCtrl.text = widget.proveedor!.nombre;
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    super.dispose();
  }

  bool get esEdicion => widget.proveedor != null;

  Future<void> _intentarGuardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _validandoDuplicado = true);

    final nombreApi = nombreCtrl.text.trim().toUpperCase();

    // 1. Validar duplicados en Firebase
    final existe = await ref
        .read(proveedorNotifierProvider.notifier)
        .existeNombre(
          empresaId: widget.empresaId,
          nombre: nombreApi,
          excluirId: widget.proveedor?.id, // Importante para edición
        );

    setState(() => _validandoDuplicado = false);

    if (existe && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Ya existe un proveedor activo con ese nombre en la empresa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    // 2. Confirmar Acción (Crear/Actualizar)
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmActionDialog(
        title: esEdicion ? 'Actualizar Proveedor' : 'Crear Proveedor',
        message: esEdicion
            ? '¿Desea actualizar el nombre a $nombreApi?'
            : '¿Desea guardar el nuevo proveedor $nombreApi?',
        icon: esEdicion ? Icons.edit : Icons.save,
        iconColor: Colors.blue,
        confirmText: esEdicion ? 'Actualizar' : 'Guardar',
        onConfirm: () async {
          final session = ref.read(sessionProvider);
          final usuarioId = session.usuario!.id;

          if (esEdicion) {
            // Lógica de Edición poblada con auditoría
            final provActualizado = widget.proveedor!.copyWith(
              nombre: nombreApi,
              usuarioModificadorId: usuarioId,
              fechaActualizacion: DateTime.now(),
            );
            await ref
                .read(proveedorNotifierProvider.notifier)
                .update(provActualizado);
          } else {
            // Lógica de Creación poblada con auditoría
            final nuevoProv = Proveedor(
              id: const Uuid().v4(),
              empresaId: widget.empresaId,
              nombre: nombreApi,
              usuarioCreadorId: usuarioId,
              usuarioModificadorId: usuarioId,
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            );
            await ref
                .read(proveedorNotifierProvider.notifier)
                .create(nuevoProv);
          }
        },
      ),
    );

    // 3. Cerrar sub-formulario si fue exitoso
    if (confirmar == true && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el estado del notifier para mostrar loading en el botón guardar
    final state = ref.watch(proveedorNotifierProvider);
    final cargandoTransaccion = state is AsyncLoading;

    return AlertDialog(
      title: Text(esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nombreCtrl,
                textCapitalization: TextCapitalization.characters, // Ayuda UI
                inputFormatters: [
                  // Forzamos que CADA letra entre en mayúsculas y bloqueamos caracteres raros si quieres
                  FilteringTextInputFormatter.allow(RegExp("[A-Z0-9 ]")),
                  // O simplemente un formatter que convierte a upper on change:
                  // TextInputFormatter.withFunction((oldValue, newValue) => newValue.copyWith(text: newValue.text.toUpperCase())),
                ],
                decoration: InputDecoration(
                  labelText: 'Nombre del Proveedor',
                  hintText: 'SOLO MAYÚSCULAS',
                  helperText: 'No se permiten duplicados en la empresa.',
                  suffixIcon: _validandoDuplicado
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingrese nombre';
                  if (v.trim().length < 2) return 'Muy corto';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: (_validandoDuplicado || cargandoTransaccion)
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (_validandoDuplicado || cargandoTransaccion)
              ? null
              : _intentarGuardar,
          child: (_validandoDuplicado || cargandoTransaccion)
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
  }
}
