import 'package:flutter/material.dart';

enum ActionDialogType { delete, update, create, info }

class ActionDialog extends StatefulWidget {
  final String titulo;
  final String mensaje;
  final ActionDialogType type;
  final Future<void> Function() onConfirm;
  final String confirmText;
  final String cancelText;

  const ActionDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    required this.type,
    required this.onConfirm,
    this.confirmText = "Confirmar",
    this.cancelText = "Cancelar",
  });

  @override
  State<ActionDialog> createState() => _ActionDialogState();
}

class _ActionDialogState extends State<ActionDialog> {
  bool _isLoading = false;

  // Configuración de colores e iconos según el tipo
  Map<String, dynamic> _getStyles() {
    switch (widget.type) {
      case ActionDialogType.delete:
        return {
          'color': Colors.red,
          'icon': Icons.delete_forever_rounded,
          'bgColor': Colors.red[50],
        };
      case ActionDialogType.update:
        return {
          'color': Colors.orange[800]!,
          'icon': Icons.edit_rounded,
          'bgColor': Colors.orange[50],
        };
      case ActionDialogType.create:
        return {
          'color': Colors.green,
          'icon': Icons.add_circle_rounded,
          'bgColor': Colors.green[50],
        };
      default:
        return {
          'color': Colors.blue,
          'icon': Icons.info_rounded,
          'bgColor': Colors.blue[50],
        };
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true); // Retorna true si éxito
    } catch (e) {
      // Puedes mostrar un snackbar aquí si quieres
      if (mounted) Navigator.of(context).pop(false); // Retorna false si error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = _getStyles();
    final Color mainColor = styles['color'] as Color;
    final IconData icon = styles['icon'] as IconData;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mainColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: mainColor, size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            widget.titulo,
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(widget.mensaje, style: const TextStyle(fontSize: 16))],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: Text(
            widget.cancelText,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: mainColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(widget.confirmText),
        ),
      ],
    );
  }
}
