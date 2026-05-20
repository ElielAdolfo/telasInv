import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart';
import 'package:inv_telas/models/historico_precio.dart';
import 'package:inv_telas/models/precio_venta.dart';
import 'package:inv_telas/models/catalogos.dart';

class PrecioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final CollectionReference<Map<String, dynamic>> _preciosRef;
  late final CollectionReference<Map<String, dynamic>> _historicoRef;
  late final CollectionReference<Map<String, dynamic>> _rollosRef;
  late final CollectionReference<Map<String, dynamic>> _telasRef;

  PrecioService() {
    _preciosRef = _db.collection(Env.col('precios_venta'));
    _historicoRef = _db.collection(Env.col('historico_precios'));
    _rollosRef = _db.collection(Env.col('rollos'));
    _telasRef = _db.collection(Env.col('tipos_tela'));
  }

  Future<List<TipoTela>> obtenerTelasEnStockSucursal(String sucursalId) async {
    try {
      final querySnapshot = await _rollosRef
          .where('sucursalId', isEqualTo: sucursalId)
          .where('activo', isEqualTo: true)
          .get();

      final Set<String> idsUnicos = querySnapshot.docs
          .map((doc) => doc.data()['tipoTelaId'] as String?)
          .whereType<String>()
          .toSet();

      if (idsUnicos.isEmpty) return [];

      List<TipoTela> telas = [];

      for (var id in idsUnicos) {
        final docTela = await _telasRef.doc(id).get();

        if (docTela.exists && docTela.data() != null) {
          telas.add(TipoTela.fromJson(docTela.data()!));
        } else {
          telas.add(TipoTela(id: id, nombre: 'Tela ID: $id'));
        }
      }

      return telas;
    } catch (e) {
      print('Error obteniendo stock de telas: $e');
      return [];
    }
  }

  Future<List<PrecioVenta>> obtenerPreciosPorSucursal(String sucursalId) async {
    final snapshot = await _preciosRef
        .where('sucursalId', isEqualTo: sucursalId)
        .where('activo', isEqualTo: true)
        .get();

    return snapshot.docs
        .map((doc) => PrecioVenta.fromJson(doc.data()))
        .toList();
  }

  Future<List<PrecioVenta>> obtenerTodosLosPrecios() async {
    final snapshot = await _preciosRef.where('activo', isEqualTo: true).get();

    return snapshot.docs
        .map((doc) => PrecioVenta.fromJson(doc.data()))
        .toList();
  }

  Future<void> guardarPrecio({
    required List<String> sucursalIds,
    required PrecioVenta precioBase,
    required String usuarioId,
    required String usuarioNombre,
    String? telaNombre,
  }) async {
    final batch = _db.batch();
    final now = DateTime.now();

    for (String sucursalId in sucursalIds) {
      Query<Map<String, dynamic>> query = _preciosRef
          .where('sucursalId', isEqualTo: sucursalId)
          .where('telaId', isEqualTo: precioBase.telaId)
          .where('activo', isEqualTo: true);

      if (precioBase.empresaId != null) {
        query = query.where('empresaId', isEqualTo: precioBase.empresaId);
      } else {
        query = query.where('empresaId', isNull: true);
      }

      final existingSnap = await query.limit(1).get();

      DocumentReference<Map<String, dynamic>> docRef;
      bool esNuevo;

      Map<String, dynamic>? existingData;

      if (existingSnap.docs.isNotEmpty) {
        docRef = existingSnap.docs.first.reference;
        esNuevo = false;
        existingData = existingSnap.docs.first.data();
      } else {
        docRef = _preciosRef.doc();
        esNuevo = true;
      }

      final precioToSave = precioBase.copyWith(
        id: docRef.id,
        sucursalId: sucursalId,
        telaNombre: telaNombre ?? precioBase.telaNombre,
        updatedAt: now,
        updatedBy: usuarioId,
        createdAt: esNuevo
            ? now
            : (existingData?['createdAt'] as Timestamp?)?.toDate() ?? now,
        createdBy: esNuevo
            ? usuarioId
            : (existingData?['createdBy'] as String?) ?? usuarioId,
      );

      _validarNegocio(precioToSave);

      final dataToSave = precioToSave.toJson();

      batch.set(docRef, dataToSave, SetOptions(merge: true));

      final historicoRef = _historicoRef.doc();

      final historico = HistoricoPrecio(
        id: historicoRef.id,
        precioId: docRef.id,
        accion: esNuevo ? 'CREATE' : 'UPDATE',
        datosAnteriores: esNuevo ? null : existingData,
        datosNuevos: dataToSave,
        usuarioId: usuarioId,
        usuarioNombre: usuarioNombre,
        fecha: now,
        sucursalId: sucursalId,
        telaId: precioToSave.telaId,
        empresaId: precioToSave.empresaId,
      );

      batch.set(historicoRef, historico.toJson());
    }

    await batch.commit();
  }

  void _validarNegocio(PrecioVenta p) {
    if (p.tienePrecioMayor && p.precioMayor != null) {
      if (p.precioMayor! > p.precioMetro) {
        throw Exception(
          'El precio mayor (${p.precioMayor}) no puede ser mayor al precio metro (${p.precioMetro}).',
        );
      }
    }

    if (p.tienePrecioRollo) {
      double limiteSuperior = p.tienePrecioMayor
          ? (p.precioMayor ?? double.infinity)
          : p.precioMetro;

      if (p.tipoPrecioRollo == 'fijo') {
        if (p.precioRolloFijo == null || p.precioRolloFijo! <= 0) {
          throw Exception('El precio fijo del rollo es requerido.');
        }
      }

      if (p.tipoPrecioRollo == 'dinamico' && p.precioMetroRollo != null) {
        if (p.precioMetroRollo! > limiteSuperior) {
          throw Exception(
            'El precio por metro de rollo debe ser menor o igual al precio de mayor/metro.',
          );
        }

        if (p.rangoMinRollo != null && p.rangoMaxRollo != null) {
          if (p.rangoMinRollo! > p.rangoMaxRollo!) {
            throw Exception(
              'El rango mínimo del rollo no puede ser mayor al máximo.',
            );
          }
        }
      }
    }
  }
}
