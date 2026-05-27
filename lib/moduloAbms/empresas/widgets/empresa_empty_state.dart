import 'package:flutter/material.dart';

class EmpresaEmptyState extends StatelessWidget {
  final VoidCallback onCrearEmpresa;
  final VoidCallback onUnirseEmpresa;
  final VoidCallback onEditarPerfil;
  final VoidCallback onCerrarSesion;

  const EmpresaEmptyState({
    super.key,
    required this.onCrearEmpresa,
    required this.onUnirseEmpresa,
    required this.onEditarPerfil,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.business_center_rounded,
                  size: 90,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  'Aún no tienes empresas asociadas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_business),
                    label: const Text('Crear Empresa'),
                    onPressed: onCrearEmpresa,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.group_add),
                    label: const Text('Unirme a Empresa'),
                    onPressed: onUnirseEmpresa,
                  ),
                ),

                const SizedBox(height: 20),

                TextButton.icon(
                  icon: const Icon(Icons.person),
                  label: const Text('Editar Perfil'),
                  onPressed: onEditarPerfil,
                ),

                TextButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  onPressed: onCerrarSesion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
