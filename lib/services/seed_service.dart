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

    print("🔍 Verificando si existen datos en Firebase...");

    final snapshot = await _firestore.collection('rollos').limit(1).get();

    if (snapshot.docs.isNotEmpty) {
      print("📦 Ya existen datos en Firebase. No se crea nada.");
      return;
    }

    print("🚀 No existen datos. Creando datos de ejemplo con IDs...");

    // En un caso real, aquí buscarías los IDs reales de los catálogos.
    // Para el ejemplo, generamos IDs únicos que simulan ser los del catálogo.
    final idTextiles = Helpers.generarId();
    final idImportadora = Helpers.generarId();
    final idFabrica = Helpers.generarId();

    final idRojo = Helpers.generarId();
    final idAzul = Helpers.generarId();
    final idVerde = Helpers.generarId();

    final idAlgodon = Helpers.generarId();
    final idPoliester = Helpers.generarId();
    final idLino = Helpers.generarId();

    final ejemplos = _datosEjemplo(
      empresaIds: [idTextiles, idImportadora, idFabrica],
      colorIds: [idRojo, idAzul, idVerde],
      tipoIds: [idAlgodon, idPoliester, idLino],
    );

    await _rolloService.createRollos(ejemplos);

    print("✅ Datos de ejemplo creados correctamente");
  }

  List<Rollo> _datosEjemplo({
    required List<String> empresaIds,
    required List<String> colorIds,
    required List<String> tipoIds,
  }) {
    return [
      Rollo(
        id: Helpers.generarId(),
        empresaId: empresaIds[0], // Textiles Bolivia
        colorId: colorIds[0], // Rojo
        codigoColor: "#B91C1C",
        tipoTelaId: tipoIds[0], // Algodón
        metraje: 120,
        fechaCreacion: DateTime.now(),
      ),
      Rollo(
        id: Helpers.generarId(),
        empresaId: empresaIds[1], // Importadora Andina
        colorId: colorIds[1], // Azul
        codigoColor: "#1E3A8A",
        tipoTelaId: tipoIds[1], // Poliéster
        metraje: 85,
        fechaCreacion: DateTime.now(),
      ),
      Rollo(
        id: Helpers.generarId(),
        empresaId: empresaIds[2], // Fábrica La Paz
        colorId: colorIds[2], // Verde
        codigoColor: "#065F46",
        tipoTelaId: tipoIds[2], // Lino
        metraje: 60,
        fechaCreacion: DateTime.now(),
      ),
    ];
  }
}
