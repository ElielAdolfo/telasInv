import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/lote.dart';
import 'package:inv_telas/services/lotes_service.dart';

// Service Provider
final lotesServiceProvider = Provider<LotesService>((ref) => LotesService());

// Lista de lotes en tiempo real
final lotesListProvider = StreamProvider<List<Lote>>((ref) {
  return ref.watch(lotesServiceProvider).streamLotes();
});

// Provider para buscar un lote por ID
final lotePorIdProvider = Provider.family<Lote?, String>((ref, id) {
  final lotesAsync = ref.watch(lotesListProvider);

  return lotesAsync.maybeWhen(
    data: (lotes) {
      try {
        return lotes.firstWhere((l) => l.id == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
