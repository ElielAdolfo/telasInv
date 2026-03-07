class Env {
  /// false = PRODUCCION
  /// true  = HELP / TEST
  static const bool isHelp = false;

  static String col(String name) {
    if (isHelp) {
      return "zz_$name";
    }
    return name;
  }
}
