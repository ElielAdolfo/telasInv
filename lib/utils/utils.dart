library utils;
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, {required String message, Color backgroundColor = const Color(0xFF1E293B)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: backgroundColor, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );
}
void showSuccessSnackBar(BuildContext context, String message) => showSnackBar(context, message: message, backgroundColor: const Color(0xFF10B981));
void showErrorSnackBar(BuildContext context, String message) => showSnackBar(context, message: message, backgroundColor: const Color(0xFFEF4444));
