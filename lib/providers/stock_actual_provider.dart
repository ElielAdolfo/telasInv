// lib/providers/stock_actual_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/stock_actual_service.dart';

final stockActualServiceProvider = Provider<StockActualService>((ref) {
  return StockActualService();
});
