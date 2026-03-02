import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, this.message, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(strokeWidth: 4, valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)))),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)), textAlign: TextAlign.center),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
