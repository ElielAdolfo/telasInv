import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:inv_telas/models/json_collection.dart';
import 'package:inv_telas/modulo_json/services/json_service.dart';

final jsonServiceProvider = Provider<JsonService>((ref) {
  return JsonService();
});

/// Colecciones individuales
final firebaseJsonProvider = FutureProvider<List<JsonCollection>>((ref) async {
  final service = ref.read(jsonServiceProvider);

  return await service.getAllCollections();
});

/// TODO el JSON junto
final firebaseFullJsonProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final service = ref.read(jsonServiceProvider);

  return await service.getAllJson();
});
