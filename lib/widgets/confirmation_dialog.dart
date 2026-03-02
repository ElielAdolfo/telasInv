import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color confirmColor;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ConfirmationDialog({
    super.key, required this.title, required this.message,
    this.confirmText = 'Confirmar', this.cancelText = 'Cancelar',
    this.confirmColor = Colors.red, this.icon, this.iconColor, this.iconBackgroundColor,
  });

  static Future<bool?> show(BuildContext context, {required String title, required String message,
      String confirmText = 'Confirmar', String cancelText = 'Cancelar', Color confirmColor = Colors.red,
      IconData? icon, Color? iconColor, Color? iconBackgroundColor}) {
    return showDialog<bool>(
      context: context, barrierDismissible: false, barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => ConfirmationDialog(
        title: title, message: message, confirmText: confirmText, cancelText: cancelText,
        confirmColor: confirmColor, icon: icon, iconColor: iconColor, iconBackgroundColor: iconBackgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: iconBackgroundColor ?? confirmColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon ?? Icons.warning_amber_rounded, size: 32, color: iconColor ?? confirmColor),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[300]!))),
                    child: Text(cancelText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(backgroundColor: confirmColor, padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                    child: Text(confirmText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeleteConfirmationDialog extends StatelessWidget {
  final String itemName;
  final String? details;

  const DeleteConfirmationDialog({super.key, required this.itemName, this.details});

  static Future<bool?> show(BuildContext context, {required String itemName, String? details}) {
    return showDialog<bool>(
      context: context, barrierDismissible: false, barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => DeleteConfirmationDialog(itemName: itemName, details: details),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: '¿Eliminar este rollo?', message: details ?? 'Esta accion no se puede deshacer.',
      confirmText: 'Eliminar', confirmColor: Colors.red,
      icon: Icons.close, iconColor: Colors.red, iconBackgroundColor: Colors.red.withValues(alpha: 0.1),
    );
  }
}

class MoveConfirmationDialog extends StatelessWidget {
  final int count;
  final double metraje;
  final String origen;
  final String destino;

  const MoveConfirmationDialog({super.key, required this.count, required this.metraje, required this.origen, required this.destino});

  static Future<bool?> show(BuildContext context, {required int count, required double metraje, required String origen, required String destino}) {
    return showDialog<bool>(
      context: context, barrierDismissible: false, barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => MoveConfirmationDialog(count: count, metraje: metraje, origen: origen, destino: destino),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConfirmationDialog(
      title: '¿Mover rollos?', message: 'Se moveran $count rollo(s) con ${metraje.toStringAsFixed(2)}m de "$origen" a "$destino".',
      confirmText: 'Mover', confirmColor: const Color(0xFF3B82F6),
      icon: Icons.swap_horiz, iconColor: const Color(0xFF3B82F6), iconBackgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
    );
  }
}
