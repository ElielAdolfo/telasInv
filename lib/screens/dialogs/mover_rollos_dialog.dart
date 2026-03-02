import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';

class MoverRollosDialog extends StatefulWidget {
  final int cantidad;
  final double metraje;
  final List<SucursalModel> sucursales;
  const MoverRollosDialog({super.key, required this.cantidad, required this.metraje, required this.sucursales});

  @override
  State<MoverRollosDialog> createState() => _MoverRollosDialogState();
}

class _MoverRollosDialogState extends State<MoverRollosDialog> {
  String? _sucursalDestino;

  Future<void> _confirmar() async {
    if (_sucursalDestino == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una sucursal destino'), backgroundColor: AppColors.warning));
      return;
    }
    final confirmado = await MoveConfirmationDialog.show(context, count: widget.cantidad, metraje: widget.metraje, origen: 'Seleccion actual', destino: _sucursalDestino!);
    if (confirmado == true) Navigator.of(context).pop(_sucursalDestino);
  }

  @override
  Widget build(BuildContext context) {
    return FormModal(
      title: 'Mover Rollos', formKey: GlobalKey<FormState>(), isLoading: false, onSave: _confirmar, saveText: 'Mover',
      onCancel: () => Navigator.of(context).pop(),
      formContent: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${widget.cantidad} rollos seleccionados', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Text('Metraje total: ${widget.metraje.toStringAsFixed(2)} m', style: const TextStyle(fontSize: 13, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          CustomDropdown<String>(
            label: 'Sucursal Destino *', value: _sucursalDestino, hint: 'Seleccionar sucursal',
            items: [
              const DropdownMenuItem(value: '', child: Text('Sin sucursal')),
              ...widget.sucursales.map((s) => DropdownMenuItem(
                value: s.nombre,
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: Color(s.colorValue), shape: BoxShape.circle)),
                  const SizedBox(width: 8), Text(s.nombre),
                ]),
              )),
            ],
            onChanged: (v) => setState(() => _sucursalDestino = v),
          ),
        ],
      ),
    );
  }
}
