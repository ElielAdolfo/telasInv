import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/ventas/precio_venta_sucursal.dart.dart';
import '../core/providers/session_provider.dart';
import 'package:collection/collection.dart';

// Obtiene todos los precios configurados de la sucursal actual
final preciosVentaSucursalProvider = StreamProvider<List<PrecioVentaSucursal>>((
  ref,
) {
  final session = ref.watch(sessionProvider);

  // CORREGIDO: Accedemos directamente a .sucursalId en lugar de .sucursal?.id
  final sucursalId = session.sucursalActual?.sucursalId ?? '';

  if (sucursalId.isEmpty) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('precios_venta_sucursal')
      .where('sucursalId', isEqualTo: sucursalId)
      .where('eliminado', isEqualTo: false)
      .where('activo', isEqualTo: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => PrecioVentaSucursal.fromMap(doc.data()))
            .toList(),
      );
});

// Helper directo para verificar si una tela específica tiene precio configurado
final precioPorTipoTelaProvider = Provider.family<PrecioVentaSucursal?, String>((
  ref,
  tipoTelaId,
) {
  final preciosAsync = ref.watch(preciosVentaSucursalProvider);
  return preciosAsync.maybeWhen(
    data: (lista) => lista.firstWhereOrNull(
      // CORREGIDO: Usar firstWhereOrNull para evitar excepciones de Null safety
      (p) => p.tipoTelaId == tipoTelaId,
    ),
    orElse: () => null,
  );
});
