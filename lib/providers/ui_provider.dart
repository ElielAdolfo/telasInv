import 'package:flutter/foundation.dart';

class UIProvider extends ChangeNotifier {
  bool _isLoadingGlobal = false;
  String _loadingMessage = 'Cargando...';
  int _currentIndex = 0;

  bool get isLoadingGlobal => _isLoadingGlobal;
  String get loadingMessage => _loadingMessage;
  int get currentIndex => _currentIndex;

  void showLoading({String message = 'Cargando...'}) {
    _isLoadingGlobal = true;
    _loadingMessage = message;
    notifyListeners();
  }

  void hideLoading() {
    _isLoadingGlobal = false;
    _loadingMessage = '';
    notifyListeners();
  }

  Future<T> withLoading<T>(Future<T> Function() operation, {String message = 'Procesando...'}) async {
    showLoading(message: message);
    try {
      return await operation();
    } finally {
      hideLoading();
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
