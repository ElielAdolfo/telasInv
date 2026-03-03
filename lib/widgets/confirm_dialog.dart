import 'package:flutter/material.dart';
import 'package:inv_telas/utils/constants.dart';

class ConfirmDialog extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final bool isDanger;
  const ConfirmDialog({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.isDanger = false,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    bool isDanger = false,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ConfirmDialog(
      titulo: titulo,
      mensaje: mensaje,
      textoConfirmar: textoConfirmar,
      isDanger: isDanger,
    ),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (isDanger ? AppColors.error : AppColors.warning)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDanger ? Icons.close : Icons.warning_amber_rounded,
              size: 32,
              color: isDanger ? AppColors.error : AppColors.warning,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDanger
                        ? AppColors.error
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(textoConfirmar, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class DeleteConfirmDialog extends StatelessWidget {
  final String titulo;
  final String info;
  const DeleteConfirmDialog({
    super.key,
    this.titulo = 'Eliminar?',
    required this.info,
  });
  static Future<bool?> show({
    required BuildContext context,
    String titulo = 'Eliminar?',
    required String info,
  }) => showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DeleteConfirmDialog(titulo: titulo, info: info),
  );

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 32, color: AppColors.error),
          ),
          const SizedBox(height: 20),
          Text(
            titulo,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              info,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Eliminar', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
