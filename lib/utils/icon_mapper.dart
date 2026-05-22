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
      case 'store':
        return Icons.store;
      case 'settings':
        return Icons.settings;
      case 'menu_book':
        return Icons.menu_book;
      case 'point_of_sale':
        return Icons.point_of_sale;

      case 'inventory_2':
        return Icons.inventory_2;
      case 'price_change':
        return Icons.price_change;
      case 'people_alt':
        return Icons.people_alt;
      case 'data_object':
        return Icons.data_object;

      // Añade más según necesites
      default:
        return Icons.error_outline;
    }
  }
}
