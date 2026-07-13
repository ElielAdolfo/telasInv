// lib/moduloPrecios/widgets/formulario_precio_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/ventas/precio_venta_sucursal.dart.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';
import '../../core/providers/session_provider.dart';

class FormularioPrecioDialog extends ConsumerStatefulWidget {
  final String tipoTelaId;
  final String nombreTela;
  final PrecioVentaSucursal? precioExistente;

  const FormularioPrecioDialog({
    super.key,
    required this.tipoTelaId,
    required this.nombreTela,
    this.precioExistente,
  });

  @override
  ConsumerState<FormularioPrecioDialog> createState() =>
      _FormularioPrecioDialogState();
}

class _FormularioPrecioDialogState
    extends ConsumerState<FormularioPrecioDialog> {
  final _formKey = GlobalKey<FormState>();

  final _cPrecioMetro = TextEditingController();
  final _cPrecioXMayor = TextEditingController();
  final _cMinXMayor = TextEditingController();
  final _cPrecioSuperMayor = TextEditingController();
  final _cMinSuperMayor = TextEditingController();
  final _cPrecioRollo = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.precioExistente != null) {
      _cPrecioMetro.text = widget.precioExistente!.precioVentaMetro.toString();
      _cPrecioXMayor.text =
          widget.precioExistente!.precioVentaXMayor?.toString() ?? '';
      _cMinXMayor.text =
          widget.precioExistente!.metrosMinimoXMayor?.toString() ?? '';
      _cPrecioSuperMayor.text =
          widget.precioExistente!.precioVentaSuperMayor?.toString() ?? '';
      _cMinSuperMayor.text =
          widget.precioExistente!.metrosMinimoSuperMayor?.toString() ?? '';
      _cPrecioRollo.text =
          widget.precioExistente!.precioXRollo?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _cPrecioMetro.dispose();
    _cPrecioXMayor.dispose();
    _cMinXMayor.dispose();
    _cPrecioSuperMayor.dispose();
    _cMinSuperMayor.dispose();
    _cPrecioRollo.dispose();
    super.dispose();
  }

  // Prepara la lógica y muestra el diálogo de confirmación
  void _confirmarGuardado() async {
    if (!_formKey.currentState!.validate()) return;

    final pMetro = double.parse(_cPrecioMetro.text);
    final pMayor = double.tryParse(_cPrecioXMayor.text);
    final mMayor = double.tryParse(_cMinXMayor.text);
    final pSuper = double.tryParse(_cPrecioSuperMayor.text);
    final mSuper = double.tryParse(_cMinSuperMayor.text);
    final pRollo = double.tryParse(_cPrecioRollo.text);

    // =========================================================================
    // VALIDACIONES LÓGICAS CRUZADAS
    // =========================================================================
    if (pMayor != null && mMayor != null) {
      if (pMayor >= pMetro) {
        _mostrarError(
          'El precio por Mayor (Bs. $pMayor) debe ser menor al precio base por metro (Bs. $pMetro).',
        );
        return;
      }
    }

    if (pSuper != null && mSuper != null) {
      if (pMayor == null || mMayor == null) {
        _mostrarError(
          'Para configurar "Súper Mayor", primero debe definir los valores de "Por Mayor".',
        );
        return;
      }
      if (mSuper <= mMayor) {
        _mostrarError(
          'El metraje de Súper Mayor ($mSuper m) debe ser mayor al de Por Mayor ($mMayor m).',
        );
        return;
      }
      if (pSuper >= pMayor) {
        _mostrarError(
          'El precio Súper Mayor (Bs. $pSuper) debe ser menor al precio por Mayor (Bs. $pMayor).',
        );
        return;
      }
    }

    final session = ref.read(sessionProvider);
    final sucursalId = session.sucursalActual?.sucursalId ?? '';
    final usuario = session.usuario?.nombre ?? 'none';

    if (sucursalId.isEmpty) {
      _mostrarError('No se pudo determinar la sucursal activa.');
      return;
    }

    // Mostramos tu ConfirmActionDialog para confirmar y ejecutar la subida con loading incluido
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (contextDialog) {
        return ConfirmActionDialog(
          title: widget.precioExistente == null
              ? 'Asignar Precios'
              : 'Modificar Precios',
          message:
              '¿Estás seguro de guardar la configuración de precios para "${widget.nombreTela}"?',
          icon: Icons.save_outlined,
          iconColor: Colors.blueAccent,
          confirmText: 'Guardar',
          onConfirm: () async {
            // Esta función se ejecuta bajo el estado "_isLoading = true" de tu diálogo
            final docRef = FirebaseFirestore.instance
                .collection('precios_venta_sucursal')
                .doc(
                  widget.precioExistente?.id ??
                      FirebaseFirestore.instance
                          .collection('precios_venta_sucursal')
                          .doc()
                          .id,
                );

            final nuevoPrecio = PrecioVentaSucursal(
              id: docRef.id,
              activo: true,
              eliminado: false,
              usuarioCreacion:
                  widget.precioExistente?.usuarioCreacion ?? usuario,
              usuarioModificacion: widget.precioExistente != null
                  ? usuario
                  : null,
              fechaCreacion:
                  widget.precioExistente?.fechaCreacion ?? DateTime.now(),
              fechaModificacion: widget.precioExistente != null
                  ? DateTime.now()
                  : null,
              sucursalId: sucursalId,
              tipoTelaId: widget.tipoTelaId,
              precioVentaMetro: pMetro,
              precioVentaXMayor: pMayor,
              metrosMinimoXMayor: mMayor,
              precioVentaSuperMayor: pSuper,
              metrosMinimoSuperMayor: mSuper,
              precioXRollo: pRollo,
            );

            await docRef.set(nuevoPrecio.toMap(), SetOptions(merge: true));
          },
        );
      },
    );

    // Si el diálogo de confirmación terminó exitosamente, cerramos también el formulario de edición
    if (confirmado == true && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración de precios guardada con éxito.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esPantallaAncha = constraints.maxWidth > 600;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.sell_outlined, color: Colors.blueAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Precios: ${widget.nombreTela}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: esPantallaAncha ? 550 : double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 650),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio Obligatorio',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cPrecioMetro,
                      decoration: const InputDecoration(
                        labelText: 'Precio por Metro Base (Bs.) *',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                        filled: true,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'El precio por metro es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Escalas por Mayor (Opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    _construirFilaDoble(
                      esPantallaAncha: esPantallaAncha,
                      campo1: TextFormField(
                        controller: _cPrecioXMayor,
                        decoration: const InputDecoration(
                          labelText: 'Precio x Mayor (Bs/m)',
                          prefixIcon: Icon(Icons.discount_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              _cMinXMayor.text.isEmpty) {
                            return 'Defina los metros mínimos';
                          }
                          return null;
                        },
                      ),
                      campo2: TextFormField(
                        controller: _cMinXMayor,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo Metros',
                          prefixIcon: Icon(Icons.add_road),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              _cPrecioXMayor.text.isEmpty) {
                            return 'Defina el precio por mayor';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    _construirFilaDoble(
                      esPantallaAncha: esPantallaAncha,
                      campo1: TextFormField(
                        controller: _cPrecioSuperMayor,
                        decoration: const InputDecoration(
                          labelText: 'Precio Súper Mayor (Bs/m)',
                          prefixIcon: Icon(Icons.star_outline),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              _cMinSuperMayor.text.isEmpty) {
                            return 'Defina los metros mínimos';
                          }
                          return null;
                        },
                      ),
                      campo2: TextFormField(
                        controller: _cMinSuperMayor,
                        decoration: const InputDecoration(
                          labelText: 'Mínimo Metros',
                          prefixIcon: Icon(Icons.add_road),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              _cPrecioSuperMayor.text.isEmpty) {
                            return 'Defina el precio súper mayor';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Venta por Rollo (Opcional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _cPrecioRollo,
                      decoration: const InputDecoration(
                        labelText: 'Precio Cerrado por Rollo Completo (Bs.)',
                        prefixIcon: Icon(Icons.layers_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _confirmarGuardado, // Llama al flujo de confirmación
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Guardar Precios',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _construirFilaDoble({
    required bool esPantallaAncha,
    required Widget campo1,
    required Widget campo2,
  }) {
    if (esPantallaAncha) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: campo1),
          const SizedBox(width: 12),
          Expanded(child: campo2),
        ],
      );
    } else {
      return Column(children: [campo1, const SizedBox(height: 12), campo2]);
    }
  }
}
