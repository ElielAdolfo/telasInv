class Validators {
  static String? required(String? value, [String? fieldName]) => (value == null || value.trim().isEmpty) ? '\ es requerido' : null;
  static String? positiveNumber(String? value, [String? fieldName]) { if (value == null || value.trim().isEmpty) return '\ es requerido'; final n = double.tryParse(value); return (n == null) ? 'Debe ser un numero valido' : (n <= 0) ? 'Debe ser mayor que cero' : null; }
}
