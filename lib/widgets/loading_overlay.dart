import 'package:flutter/material.dart';
import 'package:inv_telas/utils/constants.dart';

class LoadingOverlay extends StatelessWidget {
  final String? mensaje;
  const LoadingOverlay({super.key, this.mensaje});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 3,
            ),
            if (mensaje != null) ...[
              const SizedBox(height: 16),
              Text(mensaje!, style: AppTextStyles.body),
            ],
          ],
        ),
      ),
    ),
  );
}

class ButtonLoading extends StatelessWidget {
  const ButtonLoading({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 20,
    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
  );
}
