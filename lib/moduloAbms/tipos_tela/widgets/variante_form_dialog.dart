// archivo: widgets/variante_form_dialog.dart (Totalmente refactorizado)

import 'package:flutter/material.dart';
// CAMBIO IMPORTANTE: Importar Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/proveedor.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela_variante.dart';
import 'package:uuid/uuid.dart';

// TODO: Asegúrate de ajustar estas rutas según tu estructura de carpetas real
import '../../../core/providers/session_provider.dart';
import '../../../providers/proveedores_provider.dart'; // Need future/stream suppliers
import 'proveedores_selector_dialog.dart'; // The selector complex dialog

// CAMBIO: Ahora extiende de ConsumerStatefulWidget
class VarianteFormDialog extends ConsumerStatefulWidget {
  final TipoTelaVariante? variante;
  // CAMBIO OBLIGATORIO: Necesitamos recibir el ID de la empresa para buscar proveedores
  final String empresaId;

  const VarianteFormDialog({
    super.key,
    this.variante,
    required this.empresaId, // Actualizado en constructor
  });

  @override
  // CAMBIO: ConsumerState
  ConsumerState<VarianteFormDialog> createState() => _VarianteFormDialogState();
}

// CAMBIO: Extiende ConsumerState
class _VarianteFormDialogState extends ConsumerState<VarianteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // CAMBIO: Eliminamos proveedorCtrl, ya no lo usaremos
  // final proveedorCtrl = TextEditingController();
  final precioCtrl = TextEditingController();

  // CAMBIO: Guardamos el OBJETO Proveedor completo seleccionado (o nulo inicial)
  Proveedor? proveedorSeleccionado;
  String monedaId = 'USD';
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();

    final v = widget.variante;
    if (v == null) return;

    // precioCtrl y monedaId sin cambios
    precioCtrl.text = v.precioCompra.toString();
    monedaId = v.monedaId;

    // NOTA: v.proveedor ya no existe. selectedProveedorId = v.proveedorId;
    // No podemos buscar el objeto completo aquí fácilmente porque initState no es asíncrono.
    // Usaremos didChangeDependencies para buscarlo una vez.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lógica para inicializar el objeto proveedor si estamos editando
    if (!_inicializado && widget.variante != null) {
      _inicializarProveedorDesdeId(widget.variante!.proveedorId);
      _inicializado = true;
    }
  }

  // Busca el objeto Proveedor en la lista cargada en Firebase usando el ID guardado
  Future<void> _inicializarProveedorDesdeId(String proveedorId) async {
    if (proveedorId.isEmpty) return;

    // Obtenemos la lista (asumimos cargada o la cargamos)
    final proveedoresAsync = await ref.read(
      proveedoresFutureProvider(widget.empresaId).future,
    );

    final pEncontrado = proveedoresAsync.cast<Proveedor?>().firstWhere(
      (p) => p?.id == proveedorId,
      orElse: () => null,
    );

    if (mounted && pEncontrado != null) {
      setState(() {
        proveedorSeleccionado = pEncontrado;
      });
    }
  }

  @override
  void dispose() {
    // CAMBIO: Ya no disponemos proveedorCtrl
    // proveedorCtrl.dispose();
    precioCtrl.dispose();
    super.dispose();
  }

  // Abre el Selector Complejo que discutimos antes y espera el objeto Proveedor? elegido
  Future<void> _abrirSelectorProveedor() async {
    final proveedorElegido = await showDialog<Proveedor>(
      context: context,
      barrierDismissible: false, // Forzar uso de botones
      builder: (_) => ProveedoresSelectorDialog(
        empresaId: widget.empresaId,
        // Pasamos el ID actual para marcarlo en la lista
        proveedorIdInicial: proveedorSeleccionado?.id,
      ),
    );

    if (mounted && proveedorElegido != null) {
      setState(() {
        proveedorSeleccionado = proveedorElegido;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.variante == null ? 'Nueva Variante' : 'Editar Variante',
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ==========================================================
              // CAMBIO: Reemplazo total del TextFormField por el Selector
              // ==========================================================
              InkWell(
                onTap: _abrirSelectorProveedor,
                child: IgnorePointer(
                  // Bloquea entrada de texto manual
                  child: TextFormField(
                    // Mostramos el NOMBRE del proveedor seleccionado o placeholder vacío
                    controller: TextEditingController(
                      text: proveedorSeleccionado?.nombre ?? '',
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Proveedor (Obligatorio)',
                      hintText: 'Toque para seleccionar/gestionar',
                      prefixIcon: Icon(Icons.business_outlined),
                      // Icono visual de Dropdown
                      suffixIcon: Icon(Icons.arrow_drop_down_circle_outlined),
                    ),
                    validator: (_) {
                      // Validación manual basada en el estado
                      if (proveedorSeleccionado == null) {
                        return 'Seleccione proveedor';
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Precio compra'),
                validator: (v) {
                  if (v == null || v.isEmpty) return null; // Opcional
                  if (double.tryParse(v) == null) return 'Número inválido';
                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: monedaId,
                decoration: const InputDecoration(labelText: 'Moneda'),
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'BOB', child: Text('BOB')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    monedaId = v;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            // Validación extra de seguridad
            if (proveedorSeleccionado == null) return;

            final variante = TipoTelaVariante(
              id: widget.variante?.id ?? const Uuid().v4(),
              // CAMBIO FIJADO: Usamos proveedorId del objeto seleccionado
              proveedorId: proveedorSeleccionado!.id,
              precioCompra: double.tryParse(precioCtrl.text) ?? 0,
              monedaId: monedaId,
              // Campos de auditoría (asumimos nulos o gestionados al guardar TipoTela)
            );

            Navigator.pop(context, variante);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
