import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';

class GestionarCatalogoDialog extends StatelessWidget {
  final String tipo;
  const GestionarCatalogoDialog({super.key, required this.tipo});
  @override
  Widget build(BuildContext context) {
    return CustomModal(title: 'Gestionar $tipo', content: const Text('Funcion de gestion'), onClose: () => Navigator.of(context).pop());
  }
}

enum TipoCatalogo { empresas, sucursales, colores, tiposTela }
