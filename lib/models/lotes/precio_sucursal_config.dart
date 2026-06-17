import 'package:inv_telas/models/lotes/precio_config.dart';

class PrecioSucursalConfig {
  final String sucursalId;
  final PrecioConfig precio;

  const PrecioSucursalConfig({required this.sucursalId, required this.precio});

  factory PrecioSucursalConfig.fromMap(Map<String, dynamic> map) {
    return PrecioSucursalConfig(
      sucursalId: map['sucursalId'] ?? '',
      precio: PrecioConfig.fromMap(
        Map<String, dynamic>.from(map['precio'] ?? {}),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'sucursalId': sucursalId, 'precio': precio.toMap()};
  }
}
