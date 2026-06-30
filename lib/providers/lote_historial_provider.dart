import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/lote_historial_service.dart';

final loteHistorialServiceProvider = Provider<LoteHistorialService>((ref) {
  return LoteHistorialService();
});
