import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/services/sucursal_service.dart';

final sucursalServiceProvider = Provider<SucursalService>(
  (ref) => SucursalService(),
);

final sucursalesStreamProvider = StreamProvider.autoDispose.family((
  ref,
  String empresaId,
) {
  return ref.watch(sucursalServiceProvider).streamSucursales(empresaId);
});
