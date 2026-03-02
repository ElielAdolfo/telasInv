import 'package:flutter/material.dart';
import '../models/models.dart';
import '../constants/constants.dart';
import 'badges.dart';

class RolloListItem extends StatelessWidget {
  final RolloModel rollo;
  final bool isSelected;
  final bool isEditing;
  final VoidCallback? onTap;
  final VoidCallback? onSelect;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Widget? editWidget;
  final SucursalModel? sucursal;

  const RolloListItem({
    super.key, required this.rollo, this.isSelected = false, this.isEditing = false,
    this.onTap, this.onSelect, this.onEdit, this.onDelete, this.editWidget, this.sucursal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: isSelected ? const Color(0xFFDBEAFE) : Colors.transparent,
        border: Border(left: isSelected ? const BorderSide(color: Color(0xFF3B82F6), width: 3) : BorderSide.none)),
      child: ListTile(
        onTap: onTap,
        leading: Checkbox(value: isSelected, onChanged: isEditing ? null : (_) => onSelect?.call(), activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
        title: Row(
          children: [
            Text(rollo.codigoColor, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            const Text('•', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            StockBadge(metraje: rollo.metraje, isCompact: true),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(rollo.fechaFormateada, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              if (rollo.notas != null && rollo.notas!.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.note, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(child: Text(rollo.notas!, style: TextStyle(fontSize: 12, color: Colors.grey[500]), overflow: TextOverflow.ellipsis)),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEditing && editWidget != null) editWidget!
            else if (rollo.sucursal.isNotEmpty && sucursal != null) SucursalBadge(nombre: rollo.sucursal, color: Color(sucursal!.colorValue))
            else const SinAsignarBadge(),
            const SizedBox(width: 8),
            if (!isEditing) ...[
              IconButton(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18), color: Colors.grey, tooltip: 'Editar sucursal'),
              IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18), color: Colors.grey, tooltip: 'Eliminar'),
            ],
          ],
        ),
      ),
    );
  }
}

class ColorPreview extends StatelessWidget {
  final String hexColor;
  final double size;

  const ColorPreview({super.key, required this.hexColor, this.size = 32});

  int get _colorValue {
    try {
      String hex = hexColor.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return int.parse(hex, radix: 16);
    } catch (_) { return 0xFF94A3B8; }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: Color(_colorValue), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
    );
  }
}
