class Env {
  static const bool isDev = true;

  static String col(String name) {
    return isDev ? 'dev_$name' : name;
  }
}
