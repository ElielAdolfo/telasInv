import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/moduloAbms/menus/services/menu_abm_service.dart';

final menuAbmServiceProvider = Provider((ref) => MenuAbmService());

final menusAbmStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(menuAbmServiceProvider).streamMenus();
});
