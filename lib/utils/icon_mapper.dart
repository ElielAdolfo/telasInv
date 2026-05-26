import 'package:flutter/material.dart';

class IconMapper {
  static const Map<String, IconData> icons = {
    // ==========================
    // SISTEMA / DASHBOARD
    // ==========================
    'home': Icons.home,
    'dashboard': Icons.dashboard,
    'apps': Icons.apps,
    'menu': Icons.menu,
    'menu_open': Icons.menu_open,
    'widgets': Icons.widgets,
    'grid_view': Icons.grid_view,
    'space_dashboard': Icons.space_dashboard,
    'view_list': Icons.view_list,
    'view_module': Icons.view_module,
    'folder': Icons.folder,
    'folder_open': Icons.folder_open,

    // ==========================
    // INVENTARIO / PRODUCTOS
    // ==========================
    'inventory': Icons.inventory,
    'inventory_2': Icons.inventory_2,
    'inventory_outlined': Icons.inventory_outlined,
    'warehouse': Icons.warehouse,
    'store': Icons.store,
    'category': Icons.category,
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'add_shopping_cart': Icons.add_shopping_cart,
    'remove_shopping_cart': Icons.remove_shopping_cart,
    'sell': Icons.sell,
    'barcode': Icons.qr_code,
    'qr_code_scanner': Icons.qr_code_scanner,
    'production_quantity_limits': Icons.production_quantity_limits,
    'local_shipping': Icons.local_shipping,
    'storefront': Icons.storefront,
    'shopping_basket': Icons.shopping_basket,
    'layers': Icons.layers,
    'list_alt': Icons.list_alt,

    // ==========================
    // VENTAS / CAJA
    // ==========================
    'point_of_sale': Icons.point_of_sale,
    'payments': Icons.payments,
    'payment': Icons.payment,
    'price_change': Icons.price_change,
    'attach_money': Icons.attach_money,
    'money': Icons.money,
    'account_balance_wallet': Icons.account_balance_wallet,
    'receipt': Icons.receipt,
    'receipt_long': Icons.receipt_long,
    'credit_card': Icons.credit_card,
    'currency_exchange': Icons.currency_exchange,
    'paid': Icons.paid,
    'request_quote': Icons.request_quote,
    'calculate': Icons.calculate,
    'price_check': Icons.price_check,

    // ==========================
    // USUARIOS / RRHH
    // ==========================
    'person': Icons.person,
    'person_add': Icons.person_add,
    'person_remove': Icons.person_remove,
    'group': Icons.group,
    'groups': Icons.groups,
    'people': Icons.people,
    'people_alt': Icons.people_alt,
    'badge': Icons.badge,
    'admin_panel_settings': Icons.admin_panel_settings,
    'supervisor_account': Icons.supervisor_account,
    'manage_accounts': Icons.manage_accounts,

    // ==========================
    // CONFIGURACION
    // ==========================
    'settings': Icons.settings,
    'settings_applications': Icons.settings_applications,
    'tune': Icons.tune,
    'build': Icons.build,
    'construction': Icons.construction,
    'engineering': Icons.engineering,
    'extension': Icons.extension,
    'miscellaneous_services': Icons.miscellaneous_services,

    // ==========================
    // SEGURIDAD
    // ==========================
    'security': Icons.security,
    'verified_user': Icons.verified_user,
    'lock': Icons.lock,
    'lock_open': Icons.lock_open,
    'vpn_key': Icons.vpn_key,
    'fingerprint': Icons.fingerprint,
    'shield': Icons.shield,
    'privacy_tip': Icons.privacy_tip,
    'policy': Icons.policy,

    // ==========================
    // REPORTES / ANALITICA
    // ==========================
    'analytics': Icons.analytics,
    'bar_chart': Icons.bar_chart,
    'pie_chart': Icons.pie_chart,
    'stacked_bar_chart': Icons.stacked_bar_chart,
    'show_chart': Icons.show_chart,
    'insights': Icons.insights,
    'monitor': Icons.monitor,
    'assessment': Icons.assessment,
    'query_stats': Icons.query_stats,

    // ==========================
    // ARCHIVOS / DOCUMENTOS
    // ==========================
    'description': Icons.description,
    'article': Icons.article,
    'insert_drive_file': Icons.insert_drive_file,
    'file_copy': Icons.file_copy,
    'save': Icons.save,
    'download': Icons.download,
    'upload': Icons.upload,
    'print': Icons.print,
    'archive': Icons.archive,
    'unarchive': Icons.unarchive,

    // ==========================
    // NAVEGACION
    // ==========================
    'arrow_back': Icons.arrow_back,
    'arrow_forward': Icons.arrow_forward,
    'chevron_left': Icons.chevron_left,
    'chevron_right': Icons.chevron_right,
    'expand_less': Icons.expand_less,
    'expand_more': Icons.expand_more,
    'refresh': Icons.refresh,
    'sync': Icons.sync,
    'redo': Icons.redo,
    'undo': Icons.undo,

    // ==========================
    // ACCIONES CRUD
    // ==========================
    'add': Icons.add,
    'edit': Icons.edit,
    'delete': Icons.delete,
    'remove': Icons.remove,
    'visibility': Icons.visibility,
    'visibility_off': Icons.visibility_off,
    'search': Icons.search,
    'filter_list': Icons.filter_list,
    'sort': Icons.sort,
    'content_copy': Icons.content_copy,

    // ==========================
    // ALERTAS / ESTADOS
    // ==========================
    'check': Icons.check,
    'check_circle': Icons.check_circle,
    'cancel': Icons.cancel,
    'warning': Icons.warning,
    'error': Icons.error,
    'info': Icons.info,
    'notifications': Icons.notifications,
    'notifications_active': Icons.notifications_active,
    'priority_high': Icons.priority_high,

    // ==========================
    // COMUNICACION
    // ==========================
    'email': Icons.email,
    'chat': Icons.chat,
    'message': Icons.message,
    'call': Icons.call,
    'support_agent': Icons.support_agent,
    'forum': Icons.forum,

    // ==========================
    // FECHA / TIEMPO
    // ==========================
    'calendar_today': Icons.calendar_today,
    'event': Icons.event,
    'schedule': Icons.schedule,
    'access_time': Icons.access_time,
    'alarm': Icons.alarm,
    'timer': Icons.timer,

    // ==========================
    // UBICACION
    // ==========================
    'location_on': Icons.location_on,
    'map': Icons.map,
    'place': Icons.place,
    'pin_drop': Icons.pin_drop,
    'explore': Icons.explore,

    // ==========================
    // MULTIMEDIA
    // ==========================
    'image': Icons.image,
    'photo_camera': Icons.photo_camera,
    'videocam': Icons.videocam,
    'mic': Icons.mic,
    'volume_up': Icons.volume_up,

    // ==========================
    // BASE DE DATOS / API
    // ==========================
    'database': Icons.storage,
    'dns': Icons.dns,
    'cloud': Icons.cloud,
    'cloud_upload': Icons.cloud_upload,
    'cloud_download': Icons.cloud_download,
    'data_object': Icons.data_object,
    'api': Icons.api,
    'memory': Icons.memory,
    'terminal': Icons.terminal,
    'developer_mode': Icons.developer_mode,

    // ==========================
    // FAVORITOS
    // ==========================
    'favorite': Icons.favorite,
    'favorite_border': Icons.favorite_border,
    'star': Icons.star,
    'star_border': Icons.star_border,
    'bookmark': Icons.bookmark,

    // ==========================
    // UTILIDADES
    // ==========================
    'help': Icons.help_outline, // reservado
    'help_center': Icons.help_center,
    'question_mark': Icons.question_mark,
    'language': Icons.language,
    'public': Icons.public,
    'wifi': Icons.wifi,
    'bluetooth': Icons.bluetooth,
    'battery_full': Icons.battery_full,
    'phone_android': Icons.phone_android,
    'computer': Icons.computer,
    'laptop': Icons.laptop,
    'tablet': Icons.tablet,
  };

  static IconData getIcon(String? iconName) {
    return icons[iconName] ?? Icons.help_outline;
  }

  static bool isValidIcon(String? iconName) {
    return iconName != null &&
        icons.containsKey(iconName) &&
        iconName != 'help';
  }

  static List<String> get availableIcons =>
      icons.keys
          .where((e) => e != 'help') // ocultamos help
          .toList()
        ..sort();
}
