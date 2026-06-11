class TipoTelaValidator {
  static String? validarNombre(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingrese el nombre';
    }

    if (value.trim().length < 2) {
      return 'Nombre demasiado corto';
    }

    if (value.trim().length > 100) {
      return 'Nombre demasiado largo';
    }

    return null;
  }

  static String? validarEmpresa(String? empresaId) {
    if (empresaId == null || empresaId.isEmpty) {
      return 'Seleccione una empresa';
    }

    return null;
  }

  static String? validarVariantes(int cantidad) {
    if (cantidad <= 0) {
      return 'Debe existir al menos una variante';
    }

    return null;
  }
}
