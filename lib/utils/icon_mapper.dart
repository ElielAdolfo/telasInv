import 'package:flutter/material.dart';

class IconMapper {
  static IconData getIcon(String iconName) {
    switch (iconName) {
      case 'inventory':
        return Icons.inventory_2;
      case 'price':
        return Icons.price_change;
      case 'lotes':
        return Icons.layers;
      case 'roles':
        return Icons.admin_panel_settings;
      case 'store':
        return Icons.store;
      case 'settings':
        return Icons.settings;
      case 'menu_book':
        return Icons.menu_book;
      // Añade más según necesites
      default:
        return Icons.error_outline;
    }
  }
}
