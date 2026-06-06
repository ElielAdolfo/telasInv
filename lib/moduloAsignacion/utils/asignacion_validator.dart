class AsignacionValidator {
  const AsignacionValidator._();

  static String? validarCorreo(String correo) {
    final value = correo.trim();

    if (value.isEmpty) {
      return 'Ingrese un correo';
    }

    final regex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

    if (!regex.hasMatch(value)) {
      return 'Correo inválido';
    }

    return null;
  }

  static String? validarUsuarioYaAsignado({required bool yaExiste}) {
    if (yaExiste) {
      return 'El usuario ya pertenece a la empresa';
    }

    return null;
  }

  static String? validarSucursalDuplicada({required bool yaAsignada}) {
    if (yaAsignada) {
      return 'La sucursal ya fue asignada';
    }

    return null;
  }

  static String? validarRoles(List<String> rolesIds) {
    if (rolesIds.isEmpty) {
      return 'Debe seleccionar al menos un rol';
    }

    return null;
  }

  static String? validarSucursalSeleccionada(String? sucursalId) {
    if (sucursalId == null || sucursalId.isEmpty) {
      return 'Seleccione una sucursal';
    }

    return null;
  }
}
