import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/providers/providers.dart';
import 'package:inv_telas/utils/utils.dart';
import 'package:inv_telas/widgets/widgets.dart';

class NewRolloDialog extends ConsumerStatefulWidget {
  const NewRolloDialog({super.key});

  @override
  ConsumerState<NewRolloDialog> createState() => _NewRolloDialogState();
}

class _NewRolloDialogState extends ConsumerState<NewRolloDialog> {
  final _formKey = GlobalKey<FormState>();
  int _cantidad = 1;
  String? _tipoTela;
  String? _sucursal;
  String? _empresa;
  String? _color;
  String _codigoColor = '';
  double _metraje = 0.0;
  DateTime? _fecha;

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(tiposTelaProvider);
    final sucursales = ref.watch(sucursalesProvider);
    final empresas = ref.watch(empresasProvider);
    final colores = ref.watch(coloresProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildCantidadSelector(),
                  const SizedBox(height: 12),
                  _buildDropdownWithAdd(
                    "Tipo de Tela",
                    tipos.map((e) => e.nombre).toList(),
                    _tipoTela,
                    (v) => setState(() => _tipoTela = v),
                    _addTipoTela,
                  ),
                  _buildDropdownWithAdd(
                    "Sucursal",
                    sucursales.map((e) => e.nombre).toList(),
                    _sucursal,
                    (v) => setState(() => _sucursal = v),
                    _addSucursal,
                  ),
                  _buildDropdownWithAdd(
                    "Empresa",
                    empresas.map((e) => e.nombre).toList(),
                    _empresa,
                    (v) {
                      setState(() {
                        _empresa = v;
                        _autoFillCodigo();
                      });
                    },
                    _addEmpresa,
                  ),
                  _buildDropdownWithAdd(
                    "Color",
                    colores.map((e) => e.nombre).toList(),
                    _color,
                    (v) {
                      setState(() {
                        _color = v;
                        _autoFillCodigo();
                      });
                    },
                    _addColor,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Código de Color *",
                    ),
                    initialValue: _codigoColor,
                    onChanged: (v) => _codigoColor = v,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Metraje por Rollo (m) *",
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (v) => _metraje = double.tryParse(v) ?? 0,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  _buildDateSelector(),
                ],
              ),
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  // Helper methods for UI
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Nuevo Rollo de Tela", style: AppTextStyles.heading2),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return InputDecorator(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      child: Row(
        children: [
          const Expanded(child: Text("Cantidad de Rollos")),
          IconButton(
            onPressed: () => setState(() => _cantidad++),
            icon: const Icon(Icons.add_circle_outline),
          ),
          Text(
            "$_cantidad",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () => setState(() {
              if (_cantidad > 1) _cantidad--;
            }),
            icon: const Icon(Icons.remove_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return InputDecorator(
      decoration: const InputDecoration(labelText: "Fecha de Ingreso"),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_fecha == null ? 'Seleccionar' : Helpers.formatearFecha(_fecha)),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                "Guardar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownWithAdd(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
    VoidCallback onAdd,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              hint: Text("Seleccionar $label"),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onAdd,
            icon: const Icon(Icons.add_box_outlined),
            color: AppColors.primary,
            tooltip: "Nuevo $label",
          ),
        ],
      ),
    );
  }

  // Logic methods
  void _autoFillCodigo() {
    if (_empresa != null && _color != null) {
      final rollos = ref
          .read(rollosProvider)
          .maybeWhen(data: (d) => d, orElse: () => []);
      try {
        final lastRollo = rollos.firstWhere(
          (r) => r.empresa == _empresa && r.color == _color,
        );
        setState(() => _codigoColor = lastRollo.codigoColor);
      } catch (_) {}
    }
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _fecha = d);
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      final rollosToCreate = List.generate(
        _cantidad,
        (i) => Rollo(
          id: Helpers.generarId(),
          sucursal: _sucursal,
          empresa: _empresa!,
          color: _color!,
          codigoColor: _codigoColor,
          tipoTela: _tipoTela ?? '',
          metraje: _metraje,
          fecha: _fecha?.toIso8601String(),
          fechaCreacion: DateTime.now(),
        ),
      );
      final ok = await ref
          .read(rollosProvider.notifier)
          .crearRollos(rollosToCreate);
      if (ok && mounted) Navigator.pop(context);
    }
  }

  // Quick Adds
  void _addTipoTela() =>
      _showQuickAddDialog("Nuevo Tipo de Tela", (name) async {
        await ref
            .read(catalogServiceProvider)
            .addTipoTela(TipoTela(id: Helpers.generarId(), nombre: name));
        ref.refresh(tiposTelaProvider);
      });
  void _addSucursal() => _showQuickAddDialog("Nueva Sucursal", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addSucursal(Sucursal(id: Helpers.generarId(), nombre: name));
    ref.refresh(sucursalesProvider);
  });
  void _addEmpresa() => _showQuickAddDialog("Nueva Empresa", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addEmpresa(Empresa(id: Helpers.generarId(), nombre: name));
    ref.refresh(empresasProvider);
  });
  void _addColor() => _showQuickAddDialog("Nuevo Color", (name) async {
    await ref
        .read(catalogServiceProvider)
        .addColor(
          ColorTela(id: Helpers.generarId(), nombre: name, hex: '#3b82f6'),
        );
    ref.refresh(coloresProvider);
  });

  void _showQuickAddDialog(String title, Function(String) onSave) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Nombre"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                onSave(ctrl.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
