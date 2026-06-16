import 'package:inv_telas/models/moneda.dart';

class MonedaValidator {
  static List<String> validar({
    required Moneda moneda,
    required List<Moneda> monedasExistentes,
  }) {
    final errores = <String>[];

    _validarCodigo(moneda, errores);
    _validarNombre(moneda, errores);
    _validarSimbolo(moneda, errores);
    _validarDecimales(moneda, errores);
    _validarMonedaBase(moneda, monedasExistentes, errores);

    return errores;
  }

  static void _validarCodigo(Moneda moneda, List<String> errores) {
    final codigo = moneda.codigo.trim();

    if (codigo.isEmpty) {
      errores.add('El código es obligatorio.');
      return;
    }

    if (codigo.length != 3) {
      errores.add('El código debe tener exactamente 3 caracteres.');
    }

    final regex = RegExp(r'^[A-Z]{3}$');

    if (!regex.hasMatch(codigo.toUpperCase())) {
      errores.add('El código debe contener únicamente letras mayúsculas.');
    }
  }

  static void _validarNombre(Moneda moneda, List<String> errores) {
    if (moneda.nombre.trim().isEmpty) {
      errores.add('El nombre es obligatorio.');
    }

    if (moneda.nombre.trim().length < 2) {
      errores.add('El nombre debe tener al menos 2 caracteres.');
    }
  }

  static void _validarSimbolo(Moneda moneda, List<String> errores) {
    if (moneda.simbolo.trim().isEmpty) {
      errores.add('El símbolo es obligatorio.');
    }
  }

  static void _validarDecimales(Moneda moneda, List<String> errores) {
    if (moneda.decimales < 0) {
      errores.add('Los decimales no pueden ser negativos.');
    }

    if (moneda.decimales > 6) {
      errores.add('Los decimales no pueden ser mayores a 6.');
    }
  }

  static void _validarMonedaBase(
    Moneda moneda,
    List<Moneda> monedasExistentes,
    List<String> errores,
  ) {
    if (!moneda.esMonedaBase) {
      return;
    }

    final existeOtraMonedaBase = monedasExistentes.any(
      (m) => m.id != moneda.id && m.esMonedaBase && !m.eliminado,
    );

    if (existeOtraMonedaBase) {
      errores.add('Ya existe una moneda base para esta empresa.');
    }
  }

  static void validarOError({
    required Moneda moneda,
    required List<Moneda> monedasExistentes,
  }) {
    final errores = validar(
      moneda: moneda,
      monedasExistentes: monedasExistentes,
    );

    if (errores.isNotEmpty) {
      throw Exception(errores.join('\n'));
    }
  }
}
