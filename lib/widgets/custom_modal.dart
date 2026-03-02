import 'package:flutter/material.dart';
import '../constants/constants.dart';

class CustomModal extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final Widget content;
  final List<Widget>? actions;
  final double maxWidth;
  final double maxHeight;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const CustomModal({
    super.key, required this.title, this.subtitle, required this.content,
    this.actions, this.maxWidth = 500, this.maxHeight = 600, this.onClose, this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        if (subtitle != null) ...[const SizedBox(height: 4), subtitle!],
                      ],
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      onPressed: onClose ?? () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close), color: AppColors.textSecondary,
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFF1F5F9)),
                    ),
                ],
              ),
            ),
            Flexible(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: content)),
            if (actions != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
              ),
          ],
        ),
      ),
    );
  }
}

class FormModal extends StatelessWidget {
  final String title;
  final Widget? subtitle;
  final GlobalKey<FormState> formKey;
  final Widget formContent;
  final String saveText;
  final String cancelText;
  final bool isLoading;
  final VoidCallback? onCancel;
  final VoidCallback onSave;

  const FormModal({
    super.key, required this.title, this.subtitle, required this.formKey, required this.formContent,
    this.saveText = 'Guardar', this.cancelText = 'Cancelar', this.isLoading = false, this.onCancel, required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return CustomModal(
      title: title, subtitle: subtitle, onClose: onCancel,
      content: Form(key: formKey, child: formContent),
      actions: [
        TextButton(
          onPressed: isLoading ? null : (onCancel ?? () => Navigator.of(context).pop()),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          child: Text(cancelText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: isLoading ? null : onSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
          child: isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
            : Text(saveText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      ],
    );
  }
}
