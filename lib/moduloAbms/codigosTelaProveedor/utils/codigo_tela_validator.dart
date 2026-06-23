import 'package:inv_telas/models/abmTiposTelas/color_tela.dart';

class CodigoTelaValidator {
  static String? validarProveedor(String? proveedorId) {
    if (proveedorId == null || proveedorId.isEmpty) {
      return 'Seleccione un proveedor';
    }
    return null;
  }

  static String? validarTipoTela(String? tipoTelaId) {
    if (tipoTelaId == null || tipoTelaId.isEmpty) {
      return 'Seleccione un tipo de tela';
    }
    return null;
  }

  static String? validarCodigo(String? codigo) {
    if (codigo == null || codigo.trim().isEmpty) {
      return 'Ingrese un código';
    }
    return null;
  }

  /// Detecta colores duplicados por ID
  static bool existenColoresDuplicados(List<ColorTela> colores) {
    final ids = colores.map((e) => e.id).toList();
    return ids.length != ids.toSet().length;
  }

  /// Valida códigos duplicados usando Map<colorId, codigo>
  static bool existenCodigosDuplicados(Map<String, String> codigos) {
    final valores = codigos.values.where((e) => e.trim().isNotEmpty).toList();

    return valores.length != valores.toSet().length;
  }

  /// Validación adicional: código vacío por color
  static bool hayCodigosVacios(Map<String, String> codigos) {
    return codigos.values.any((c) => c.trim().isEmpty);
  }
}
