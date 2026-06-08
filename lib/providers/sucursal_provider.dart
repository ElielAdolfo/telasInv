import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/models/sucursal.dart';
import 'package:inv_telas/services/sucursal_service.dart';

final sucursalServiceProvider = Provider<SucursalService>(
  (ref) => SucursalService(),
);

final sucursalesProvider = FutureProvider.family<List<Sucursal>, String>((
  ref,
  empresaId,
) async {
  return ref.read(sucursalServiceProvider).getSucursales(empresaId);
});
