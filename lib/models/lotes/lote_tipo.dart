enum LoteTipo { local, importacion }

extension LoteTipoExtension on LoteTipo {
  String get nombre {
    switch (this) {
      case LoteTipo.local:
        return 'LOCAL';

      case LoteTipo.importacion:
        return 'IMPORTACION';
    }
  }

  static LoteTipo fromString(String value) {
    return LoteTipo.values.firstWhere(
      (e) => e.nombre == value,
      orElse: () => LoteTipo.local,
    );
  }
}
