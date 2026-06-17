enum LoteEstado { borrador, enTransito, revision, finalizado, cancelado }

extension LoteEstadoExtension on LoteEstado {
  String get nombre {
    switch (this) {
      case LoteEstado.borrador:
        return 'BORRADOR';

      case LoteEstado.enTransito:
        return 'EN_TRANSITO';

      case LoteEstado.revision:
        return 'REVISION';

      case LoteEstado.finalizado:
        return 'FINALIZADO';

      case LoteEstado.cancelado:
        return 'CANCELADO';
    }
  }

  static LoteEstado fromString(String value) {
    return LoteEstado.values.firstWhere(
      (e) => e.nombre == value,
      orElse: () => LoteEstado.borrador,
    );
  }
}
