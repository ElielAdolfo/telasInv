import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/abmTiposTelas/color_tela.dart';

class ColorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'colores';

  /// Escucha en tiempo real los colores activos de una empresa específica
  Stream<List<ColorTela>> streamColoresPorEmpresa(String empresaId) {
    return _db
        .collection(_collection)
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
    final docRef = _db.collection(_collection).doc();
    final colorConId = color.copyWith(
      id: docRef.id,
      fechaCreacion: DateTime.now(),
    );
    await docRef.set(colorConId.toJson());
  }

  /// Actualiza los cambios de un color existente
  Future<void> actualizarColor(ColorTela color) async {
    await _db
        .collection(_collection)
        .doc(color.id)
        .update(color.copyWith(fechaActualizacion: DateTime.now()).toJson());
  }

  /// Modificación / Baja Lógica (update eliminado = true OR false si se desea restaurar)
  Future<void> modificarEstadoEliminado({
    required String id,
    required bool eliminado,
    required String usuarioId,
  }) async {
    await _db.collection(_collection).doc(id).update({
      'eliminado': eliminado,
      'activo': !eliminado, // Si está eliminado, activo pasa a ser false
      'usuarioEliminadorId': eliminado ? usuarioId : null,
      'fechaEliminacion': eliminado ? FieldValue.serverTimestamp() : null,
      'usuarioModificadorId': usuarioId,
      'fechaActualizacion': FieldValue.serverTimestamp(),
    });
  }
}
