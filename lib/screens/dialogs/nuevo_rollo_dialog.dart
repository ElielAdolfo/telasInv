import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';
import 'nuevo_catalogo_dialog.dart';

class NuevoRolloDialog extends StatefulWidget {
  const NuevoRolloDialog({super.key});
  @override
  State<NuevoRolloDialog> createState() => _NuevoRolloDialogState();
}

class _NuevoRolloDialogState extends State<NuevoRolloDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cantidadController = TextEditingController(text: '1');
  final _metrajeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _notasController = TextEditingController();
  final _fechaController = TextEditingController();

  String? _sucursalSeleccionada;
  String? _empresaSeleccionada;
  String? _colorSeleccionado;
  String? _tipoTelaSeleccionado;
  DateTime? _fechaSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fechaSeleccionada = DateTime.now();
    _fechaController.text = _formatDate(_fechaSeleccionada!);
    _cantidadController.addListener(() => setState(() {}));
    _metrajeController.addListener(() => setState(() {}));
  }

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _actualizarCodigoSugerido() {
    if (_empresaSeleccionada != null && _colorSeleccionado != null) {
      final provider = context.read<InventarioProvider>();
      final codigo = provider.getCodigoSugerido(_empresaSeleccionada!, _colorSeleccionado!);
      if (codigo != null) _codigoController.text = codigo;
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose(); _metrajeController.dispose(); _codigoController.dispose();
    _notasController.dispose(); _fechaController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final provider = context.read<InventarioProvider>();
      final cantidad = int.tryParse(_cantidadController.text) ?? 1;
      final metraje = double.tryParse(_metrajeController.text) ?? 0;

      final nuevosRollos = List.generate(cantidad, (index) => RolloModel(
        id: RolloModel.generarId(), sucursal: _sucursalSeleccionada ?? '', empresa: _empresaSeleccionada!,
        color: _colorSeleccionado!, codigoColor: _codigoController.text.trim().toUpperCase(),
        tipoTela: _tipoTelaSeleccionado ?? '', metraje: metraje, fecha: _fechaController.text,
        notas: _notasController.text.trim().isNotEmpty ? _notasController.text.trim() : null,
        fechaCreacion: DateTime.now(),
      ));

      await provider.guardarRollos(nuevosRollos);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Guardado correctamente'), backgroundColor: AppColors.success));
        Navigator.of(context).pop();
      }
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InventarioProvider>(
      builder: (context, provider, child) {
        final cantidad = int.tryParse(_cantidadController.text) ?? 1;
        final metraje = double.tryParse(_metrajeController.text) ?? 0;
        return FormModal(
          title: AppStrings.nuevoRollo, formKey: _formKey, isLoading: _isLoading, onSave: _guardar,
          onCancel: () => Navigator.of(context).pop(),
          formContent: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.inventory, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('Se crearan $cantidad rollo(s) - Total: ${(cantidad * metraje).toStringAsFixed(2)} m',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: 'Cantidad', value: _cantidadController.text,
                items: ['1', '2', '3', '4', '5', '10', '20', '50'].map((v) => DropdownMenuItem(value: v, child: Text('$v rollos'))).toList(),
                onChanged: (v) { _cantidadController.text = v ?? '1'; setState(() {}); },
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: AppStrings.tipoTela, value: _tipoTelaSeleccionado, hint: 'Seleccionar tipo',
                items: provider.tiposTela.map((t) => DropdownMenuItem(value: t.nombre, child: Text(t.nombre))).toList(),
                onChanged: (v) => setState(() => _tipoTelaSeleccionado = v),
                onAddNew: () => _agregarCatalogo(provider, 'tipoTela'),
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: '${AppStrings.sucursal} (opcional)', value: _sucursalSeleccionada, hint: AppStrings.sinAsignar,
                items: provider.sucursales.map((s) => DropdownMenuItem(value: s.nombre, child: Text(s.nombre))).toList(),
                onChanged: (v) => setState(() => _sucursalSeleccionada = v),
                onAddNew: () => _agregarCatalogo(provider, 'sucursal'),
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: '${AppStrings.empresa} *', value: _empresaSeleccionada, hint: AppStrings.seleccionarEmpresa,
                items: provider.empresas.map((e) => DropdownMenuItem(value: e.nombre, child: Text(e.nombre))).toList(),
                onChanged: (v) { setState(() { _empresaSeleccionada = v; _actualizarCodigoSugerido(); }); },
                onAddNew: () => _agregarCatalogo(provider, 'empresa'),
                validator: (v) => v == null ? AppStrings.campoRequerido : null,
              ),
              const SizedBox(height: 16),
              CustomDropdown<String>(
                label: '${AppStrings.color} *', value: _colorSeleccionado, hint: AppStrings.seleccionarColor,
                items: provider.colores.map((c) => DropdownMenuItem(
                  value: c.nombre,
                  child: Row(children: [
                    Container(width: 20, height: 20, decoration: BoxDecoration(color: Color(c.colorValue), borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 8), Text(c.nombre),
                  ]),
                )).toList(),
                onChanged: (v) { setState(() { _colorSeleccionado = v; _actualizarCodigoSugerido(); }); },
                onAddNew: () => _agregarCatalogo(provider, 'color'),
                validator: (v) => v == null ? AppStrings.campoRequerido : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(label: '${AppStrings.codigoColor} *', controller: _codigoController, hint: 'Ej: AZ-001',
                validator: (v) => v == null || v.trim().isEmpty ? AppStrings.campoRequerido : null),
              const SizedBox(height: 16),
              CustomNumberField(label: '${AppStrings.metrajePorRollo} *', controller: _metrajeController, minValue: 0.01, hint: '0.00'),
              const SizedBox(height: 16),
              CustomDateField(label: AppStrings.fechaIngreso, controller: _fechaController, initialDate: _fechaSeleccionada,
                onDateSelected: (d) => _fechaSeleccionada = d),
              const SizedBox(height: 16),
              CustomTextField(label: '${AppStrings.notas} (opcional)', controller: _notasController, hint: 'Observaciones...', maxLines: 2),
            ],
          ),
        );
      },
    );
  }

  Future<void> _agregarCatalogo(InventarioProvider provider, String tipo) async {
    final resultado = await showDialog<Map<String, dynamic>>(context: context, barrierDismissible: false,
      builder: (context) => NuevoCatalogoDialog(tipo: tipo));
    if (resultado == null) return;

    final nombre = resultado['nombre'] as String;
    final color = resultado['color'] as String?;

    switch (tipo) {
      case 'empresa': if (!provider.existeEmpresa(nombre)) await provider.guardarEmpresa(EmpresaModel(id: EmpresaModel.generarId(), nombre: nombre)); setState(() => _empresaSeleccionada = nombre); break;
      case 'sucursal': if (!provider.existeSucursal(nombre)) await provider.guardarSucursal(SucursalModel(id: SucursalModel.generarId(), nombre: nombre, color: color ?? '#3b82f6')); setState(() => _sucursalSeleccionada = nombre); break;
      case 'color': if (!provider.existeColor(nombre)) await provider.guardarColor(ColorTelaModel(id: ColorTelaModel.generarId(), nombre: nombre, hex: color ?? '#94a3b8')); setState(() => _colorSeleccionado = nombre); break;
      case 'tipoTela': if (!provider.existeTipoTela(nombre)) await provider.guardarTipoTela(TipoTelaModel(id: TipoTelaModel.generarId(), nombre: nombre)); setState(() => _tipoTelaSeleccionado = nombre); break;
    }
  }
}
