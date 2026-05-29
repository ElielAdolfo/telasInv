import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/models/empresa.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/providers/sucursal_provider.dart';
import 'package:inv_telas/widgets/confirm_action_dialog.dart';

import 'empresa_selector.dart';
import 'encargados_selector.dart';

class SucursalFormDialog extends ConsumerStatefulWidget {
  final Sucursal? sucursal;

  const SucursalFormDialog({super.key, required this.sucursal});

  @override
  ConsumerState<SucursalFormDialog> createState() => _SucursalFormDialogState();
}

class _SucursalFormDialogState extends ConsumerState<SucursalFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nombreCtrl;

  late TextEditingController direccionCtrl;

  late TextEditingController whatsappCtrl;

  late TextEditingController nitCtrl;

  bool _saving = false;

  Empresa? empresaSeleccionada;

  List<String> encargadosIds = [];

  String tipoPagoNit = 'Mensual';

  DateTime? fechaPagoNit;

  final tiposPago = const [
    'Mensual',
    'Bimestral',
    'Trimestral',
    'Semestral',
    'Anual',
    'Personalizado',
  ];

  @override
  void initState() {
    super.initState();

    final sucursal = widget.sucursal;

    final session = ref.read(sessionProvider);

    nombreCtrl = TextEditingController(text: sucursal?.nombre ?? '');

    direccionCtrl = TextEditingController(text: sucursal?.direccion ?? '');

    whatsappCtrl = TextEditingController(text: sucursal?.whatsapp ?? '');

    nitCtrl = TextEditingController(text: sucursal?.nit ?? '');

    encargadosIds = List<String>.from(sucursal?.encargadosIds ?? []);

    tipoPagoNit = sucursal?.tipoPagoNit ?? 'Mensual';

    fechaPagoNit = sucursal?.fechaPagoNit;

    /// EMPRESA INICIAL
    empresaSeleccionada = widget.sucursal != null
        ? session.empresasDisponibles.firstWhere((e) {
            return e.id == widget.sucursal!.empresaId;
          }, orElse: () => session.empresaActual!)
        : session.empresaActual;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    direccionCtrl.dispose();
    whatsappCtrl.dispose();
    nitCtrl.dispose();

    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (empresaSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione una empresa')));

      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmActionDialog(
        title: widget.sucursal == null
            ? 'Crear sucursal'
            : 'Actualizar sucursal',

        message: widget.sucursal == null
            ? '¿Desea crear esta sucursal?'
            : '¿Desea actualizar esta sucursal?',

        icon: Icons.store,

        iconColor: Colors.blue,

        onConfirm: () async {},
      ),
    );

    if (confirm != true) {
      return;
    }

    try {
      setState(() {
        _saving = true;
      });

      final session = ref.read(sessionProvider);

      final userId = session.usuario!.id;

      final sucursal = Sucursal(
        id: widget.sucursal?.id ?? '',

        empresaId: empresaSeleccionada!.id,

        nombre: nombreCtrl.text.trim(),

        direccion: direccionCtrl.text.trim(),

        whatsapp: whatsappCtrl.text.trim().isEmpty
            ? null
            : whatsappCtrl.text.trim(),

        nit: nitCtrl.text.trim().isEmpty ? null : nitCtrl.text.trim(),

        tipoPagoNit: tipoPagoNit,

        fechaPagoNit: fechaPagoNit,

        encargadosIds: encargadosIds,
      );

      await ref
          .read(sucursalServiceProvider)
          .guardarSucursal(sucursal: sucursal, usuarioId: userId);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.sucursal == null
                ? 'Sucursal creada correctamente'
                : 'Sucursal actualizada correctamente',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final mobile = width < 700;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: mobile ? double.infinity : 700),

        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Form(
            key: _formKey,

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.sucursal == null
                        ? 'Nueva sucursal'
                        : 'Editar sucursal',

                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 24),

                  EmpresaSelector(
                    initialEmpresa: empresaSeleccionada,

                    onChanged: (empresa) {
                      empresaSeleccionada = empresa;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: nombreCtrl,

                    decoration: const InputDecoration(
                      labelText: 'Nombre sucursal *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.store),
                    ),

                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo requerido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: direccionCtrl,

                    maxLines: 2,

                    decoration: const InputDecoration(
                      labelText: 'Dirección *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),

                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo requerido';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  if (!mobile)
                    Row(
                      children: [
                        Expanded(child: _buildWhatsapp()),
                        const SizedBox(width: 12),
                        Expanded(child: _buildNit()),
                      ],
                    )
                  else ...[
                    _buildWhatsapp(),
                    const SizedBox(height: 16),
                    _buildNit(),
                  ],

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: tipoPagoNit,

                    items: tiposPago
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),

                    onChanged: (v) {
                      if (v == null) return;

                      setState(() {
                        tipoPagoNit = v;
                      });
                    },

                    decoration: const InputDecoration(
                      labelText: 'Tipo pago NIT',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  EncargadosSelector(
                    empresa: empresaSeleccionada,
                    selectedIds: encargadosIds,
                    onChanged: (ids) {
                      encargadosIds = ids;
                    },
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,

                    children: [
                      TextButton(
                        onPressed: _saving
                            ? null
                            : () {
                                Navigator.pop(context);
                              },

                        child: const Text('Cancelar'),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton.icon(
                        onPressed: _saving ? null : _guardar,

                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save),

                        label: Text(
                          widget.sucursal == null ? 'Crear' : 'Guardar',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsapp() {
    return TextFormField(
      controller: whatsappCtrl,

      keyboardType: TextInputType.phone,

      decoration: const InputDecoration(
        labelText: 'WhatsApp',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.phone),
      ),
    );
  }

  Widget _buildNit() {
    return TextFormField(
      controller: nitCtrl,

      decoration: const InputDecoration(
        labelText: 'NIT',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.badge),
      ),
    );
  }
}
