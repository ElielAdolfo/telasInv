class SeedConfig {
  SeedConfig._();

  /// ---------------------------------------------------------
  /// CONFIGURACIÓN DE DATOS SEMILLA (SEED)
  /// ---------------------------------------------------------
  ///
  /// false -> NO ejecuta precarga de datos
  /// true  -> Inserta datos iniciales en Firebase
  ///
  /// ⚠️ IMPORTANTE:
  /// Mantener en FALSE cuando ya tengas:
  /// - roles creados
  /// - menús configurados
  /// - usuarios reales
  /// - permisos definidos
  ///
  /// Solo activar temporalmente en una BD vacía.
  /// crear inicial
  /// ---------------------------------------------------------
  static const bool enableSeedData = true;
}
