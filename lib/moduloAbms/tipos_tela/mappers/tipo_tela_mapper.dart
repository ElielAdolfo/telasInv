import 'package:inv_telas/models/abmTiposTelas/tipo_tela.dart';

class TipoTelaMapper {
  const TipoTelaMapper._();

  /// ==========================================
  /// NOMBRE
  /// ==========================================
  static String nombre(TipoTela tipoTela) {
    return tipoTela.nombre;
  }

  /// ==========================================
  /// ESTADO
  /// ==========================================
  static String estado(TipoTela tipoTela) {
    if (tipoTela.eliminado) {
      return 'Eliminado';
    }

    return tipoTela.activo ? 'Activo' : 'Inactivo';
  }

  /// ==========================================
  /// TOTAL VARIANTES
  /// ==========================================
  static int totalVariantes(TipoTela tipoTela) {
    return tipoTela.variantes.length;
  }

  /// ==========================================
  /// USUARIO REGISTRO
  /// ==========================================
  static String usuarioRegistro(TipoTela tipoTela) {
    return tipoTela.usuarioCreadorId ?? '-';
  }

  /// ==========================================
  /// USUARIO MODIFICACION
  /// ==========================================
  static String usuarioModificacion(TipoTela tipoTela) {
    return tipoTela.usuarioModificadorId ?? '-';
  }

  /// ==========================================
  /// USUARIO ELIMINACION
  /// ==========================================
  static String usuarioEliminacion(TipoTela tipoTela) {
    return tipoTela.usuarioEliminadorId ?? '-';
  }

  /// ==========================================
  /// FECHA REGISTRO
  /// ==========================================
  static DateTime? fechaRegistro(TipoTela tipoTela) {
    return tipoTela.fechaCreacion;
  }

  /// ==========================================
  /// FECHA MODIFICACION
  /// ==========================================
  static DateTime? fechaModificacion(TipoTela tipoTela) {
    return tipoTela.fechaActualizacion;
  }

  /// ==========================================
  /// FECHA ELIMINACION
  /// ==========================================
  static DateTime? fechaEliminacion(TipoTela tipoTela) {
    return tipoTela.fechaEliminacion;
  }

  /// ==========================================
  /// TIENE VARIANTES
  /// ==========================================
  static bool tieneVariantes(TipoTela tipoTela) {
    return tipoTela.variantes.isNotEmpty;
  }

  /// ==========================================
  /// ESTA ACTIVO
  /// ==========================================
  static bool estaActivo(TipoTela tipoTela) {
    return tipoTela.activo && !tipoTela.eliminado;
  }
}
