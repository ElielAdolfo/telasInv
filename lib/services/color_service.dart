import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/config/env.dart'; // 👈 Agregamos el import de tus environments
import '../models/abmTiposTelas/color_tela.dart';

class ColorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 👈 Reemplazamos el String hardcodeado por un getter dinámico
  CollectionReference<Map<String, dynamic>> get _colorRef =>
      _db.collection(Env.col('colores'));

  /// Escucha en tiempo real los colores activos de una empresa específica
  Stream<List<ColorTela>> streamColoresPorEmpresa(String empresaId) {
    return _colorRef // 👈 Cambiado
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ColorTela.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Registra un nuevo color autogenerando el ID de documento
  Future<void> crearColor(ColorTela color) async {
    final docRef = _colorRef.doc(); // 👈 Cambiado
    final colorConId = color.copyWith(
      id: docRef.id,
      fechaCreacion: DateTime.now(),
    );
    await docRef.set(colorConId.toJson());
  }

  /// Actualiza los cambios de un color existente
  Future<void> actualizarColor(ColorTela color) async {
    await _colorRef // 👈 Cambiado
        .doc(color.id)
        .update(color.copyWith(fechaActualizacion: DateTime.now()).toJson());
  }

  /// Modificación / Baja Lógica (update eliminado = true OR false si se desea restaurar)
  Future<void> modificarEstadoEliminado({
    required String id,
    required bool eliminado,
    required String usuarioId,a
  }) async {
    await _colorRef.doc(id).update({
      // 👈 Cambiado
      'eliminado': eliminado,
      'activo': !eliminado, // Si está eliminado, activo pasa a ser false
      'usuarioEliminadorId': eliminado ? usuarioId : null,
      'fechaEliminacion': eliminado ? FieldValue.serverTimestamp() : null,
      'usuarioModificadorId': usuarioId,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ColorTela>> getByEmpresa(String empresaId) async {
    final snap = await _colorRef
        .where('empresaId', isEqualTo: empresaId)
        .where('eliminado', isEqualTo: false)
        .get();

    return snap.docs.map((e) => ColorTela.fromJson(e.data(), e.id)).toList();
  }

  /// Escucha los colores asignados a una combinación específica de proveedor y tipo de tela
  Stream<List<Map<String, dynamic>>> streamColoresPorTelaProveedor({
    required String empresaId,
    required String proveedorId,
    required String tipoTelaId,
  }) {
    return _db
        .collection(Env.col('codigoUnicoTelaProveedor'))
        .where('empresaId', isEqualTo: empresaId)
        .where('proveedorId', isEqualTo: proveedorId)
        .where('tipoTelaId', isEqualTo: tipoTelaId)
        .where('eliminado', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return [];

          // Extraemos la lista de mapas del campo 'colores' del primer documento coincidente
          final data = snapshot.docs.first.data();
          final coloresLista = data['colores'] as List<dynamic>? ?? [];

          return coloresLista.map((c) => Map<String, dynamic>.from(c)).toList();
        });
  }
}
