import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/env.dart';
import '../models/ventas/jornada_laboral.dart';

class VentasService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _jornadasRef =>
      _db.collection(Env.col('jornadas_laborales'));

  Future<JornadaLaboral?> obtenerJornadaActiva(String sucursalId) async {
    final snap = await _jornadasRef
        .where('sucursalId', isEqualTo: sucursalId)
        .where('abierta', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      return null;
    }

    return JornadaLaboral.fromMap(snap.docs.first.data());
  }

  Future<JornadaLaboral?> obtenerUltimaJornadaDeHoy(
    String sucursalId,
    String fechaHoy,
  ) async {
    try {
      print('======================================');
      print('BUSCANDO ULTIMA JORNADA');
      print('Sucursal: $sucursalId');
      print('Fecha: $fechaHoy');
      print('======================================');

      final snap = await _jornadasRef
          .where('sucursalId', isEqualTo: sucursalId)
          .where('fechaDia', isEqualTo: fechaHoy)
          .orderBy('fechaApertura', descending: true)
          .limit(1)
          .get();

      print('Documentos encontrados: ${snap.docs.length}');

      if (snap.docs.isEmpty) {
        return null;
      }

      return JornadaLaboral.fromMap(snap.docs.first.data());
    } catch (e, st) {
      print('======================================');
      print('ERROR FIRESTORE');
      print(e);
      print('');
      print('STACKTRACE');
      print(st);
      print('======================================');

      rethrow;
    }
  }

  Future<void> registrarJornada(JornadaLaboral jornada) async {
    await _jornadasRef.doc(jornada.id).set(jornada.toMap());
  }

  Future<void> actualizarJornada(JornadaLaboral jornada) async {
    await _jornadasRef.doc(jornada.id).update(jornada.toMap());
  }
}
