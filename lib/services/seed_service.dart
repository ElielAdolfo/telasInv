import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inv_telas/models/models.dart';
import 'package:inv_telas/services/rollo_service.dart';
import 'package:inv_telas/utils/helpers.dart';
import '../config/seed_config.dart';

class SeedService {
  final RolloService _rolloService = RolloService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    if (!SeedConfig.enableSeedData) {
      print("⛔ Precarga desactivada");
      return;
    }

    print("🔎 Verificando si existen datos en Firebase...");

    final snapshot = await _firestore.collection('rollos').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      print("📦 Ya existen datos en Firebase. No se crea nada.");
      return;
    }

    print("🚀 No existen datos. Creando datos de ejemplo...");

    final ejemplos = _datosEjemplo();

    await _rolloService.createRollos(ejemplos);

    print("✅ Datos de ejemplo creados correctamente");
  }

  List<Rollo> _datosEjemplo() {
    return [
      Rollo(
        id: Helpers.generarId(),
        empresa: "Textiles Bolivia",
        color: "Rojo Carmesí",
        codigoColor: "#B91C1C",
        tipoTela: "Algodón",
        metraje: 120,
        fechaCreacion: DateTime.now(),
      ),
      Rollo(
        id: Helpers.generarId(),
        empresa: "Importadora Andina",
        color: "Azul Marino",
        codigoColor: "#1E3A8A",
        tipoTela: "Poliéster",
        metraje: 85,
        fechaCreacion: DateTime.now(),
      ),
      Rollo(
        id: Helpers.generarId(),
        empresa: "Fábrica La Paz",
        color: "Verde Esmeralda",
        codigoColor: "#065F46",
        tipoTela: "Lino",
        metraje: 60,
        fechaCreacion: DateTime.now(),
      ),
    ];
  }
}
