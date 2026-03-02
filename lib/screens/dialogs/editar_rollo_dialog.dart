import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../../constants/constants.dart';

class EditarRolloDialog extends StatelessWidget {
  const EditarRolloDialog({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomModal(title: 'Editar Rollo', content: const Text('Funcion de edicion'), onClose: () => Navigator.of(context).pop());
  }
}
