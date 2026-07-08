import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';
import 'package:inv_telas/providers/tipo_tela_provider.dart';

final ventasMapaTiposTelaProvider =
    FutureProvider.family<Map<String, TipoTela>, String>((
      ref,
      empresaId,
    ) async {
      final lista = await ref.watch(tiposTelaProvider(empresaId).future);

      return {for (final tela in lista) tela.id: tela};
    });
