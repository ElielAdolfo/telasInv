import 'package:flutter/material.dart';
import '../constants/constants.dart';

class StockBadge extends StatelessWidget {
  final double metraje;
  final bool isCompact;

  const StockBadge({super.key, required this.metraje, this.isCompact = false});

  Color get _backgroundColor {
    if (metraje >= 50) return const Color(0xFFDCFCE7);
    if (metraje >= 20) return const Color(0xFFFEF9C3);
    return const Color(0xFFFEE2E2);
  }

  Color get _textColor {
    if (metraje >= 50) return const Color(0xFF166534);
    if (metraje >= 20) return const Color(0xFF854D0E);
    return const Color(0xFF991B1B);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _backgroundColor, borderRadius: BorderRadius.circular(9999)),
      child: Text('${metraje.toStringAsFixed(2)} m', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textColor)),
    );
  }
}

class SucursalBadge extends StatelessWidget {
  final String nombre;
  final Color color;
  final int? count;

  const SucursalBadge({super.key, required this.nombre, required this.color, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(count != null ? '$nombre ($count)' : nombre, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
    );
  }
}

class SinAsignarBadge extends StatelessWidget {
  final int? count;
  const SinAsignarBadge({super.key, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1))),
      child: Text(count != null ? 'Sin Asignar ($count)' : 'Sin Asignar',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
    );
  }
}

class CantidadBadge extends StatelessWidget {
  final int cantidad;
  final Color backgroundColor;
  final Color textColor;

  const CantidadBadge({super.key, required this.cantidad, this.backgroundColor = const Color(0xFFDBEAFE), this.textColor = const Color(0xFF1D4ED8)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: Center(child: Text(cantidad.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor))),
    );
  }
}

class CodigoBadge extends StatelessWidget {
  final String codigo;
  const CodigoBadge({super.key, required this.codigo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Text(codigo, style: const TextStyle(fontSize: 14, fontFamily: 'monospace', color: Color(0xFF374151))),
    );
  }
}
