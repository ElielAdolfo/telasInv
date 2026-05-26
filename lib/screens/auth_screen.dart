import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inv_telas/core/providers/session_provider.dart';
import 'package:inv_telas/core/screens/principal_shell.dart';
import '../../../models/usuario.dart';
import '../../../utils/styles.dart';
import '../providers/auth_provider.dart';

// Importa tu pantalla de inicio cuando la tengas
// import 'package:inventario_telas/screens/homeScreen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores Login
  final _emailLoginCtrl = TextEditingController();
  final _passLoginCtrl = TextEditingController();

  // Controladores Registro
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl = TextEditingController();
  final _nameRegCtrl = TextEditingController();

  // Estado UI local
  bool _isLoading = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listener para redirigir automáticamente si ya está logueado
    Future.microtask(() {
      ref.listenManual<AsyncValue<Usuario?>>(authProvider, (prev, next) async {
        next.whenData((user) async {
          if (user != null && mounted) {
            // Inicializar sesión
            await ref.read(sessionProvider.notifier).initSession(user);

            // Navegar al shell principal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const PrincipalShell()),
            );
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailLoginCtrl.dispose();
    _passLoginCtrl.dispose();
    _emailRegCtrl.dispose();
    _passRegCtrl.dispose();
    _nameRegCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    if (_emailLoginCtrl.text.isEmpty || _passLoginCtrl.text.isEmpty) {
      _showError("Complete todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    final errorMsg = await ref
        .read(authProvider.notifier)
        .login(_emailLoginCtrl.text, _passLoginCtrl.text);

    if (mounted) setState(() => _isLoading = false);

    if (errorMsg != null) {
      _showError(errorMsg);
    }
  }

  Future<void> _handleRegister() async {
    if (_isLoading) return;

    if (_emailRegCtrl.text.isEmpty ||
        _passRegCtrl.text.isEmpty ||
        _nameRegCtrl.text.isEmpty) {
      _showError("Complete todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    final errorMsg = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailRegCtrl.text.trim(),
          pass: _passRegCtrl.text.trim(),
          nombre: _nameRegCtrl.text.trim(),

          /// NUEVO
          empresaId: 'empAdmin',

          /// OJO: minúsculas
          rolId: 'vendedor',
        );

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (errorMsg != null) {
      _showError(errorMsg);
    } else {
      _showSuccess("Cuenta creada. Ahora inicie sesión.");

      /// limpiar form
      _emailRegCtrl.clear();
      _passRegCtrl.clear();
      _nameRegCtrl.clear();

      /// volver al login
      _tabController.animateTo(0);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary.withOpacity(0.8), AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 50,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 10),
                      Text("Inventario Telas", style: AppTextStyles.heading2),
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primary,
                        indicatorColor: AppColors.primary,
                        tabs: const [
                          Tab(text: "Iniciar Sesión"),
                          Tab(text: "Registrar"),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [_buildLoginForm(), _buildRegisterForm()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailLoginCtrl,
          decoration: const InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passLoginCtrl,
          decoration: InputDecoration(
            labelText: "Contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () => setState(() => _obscurePass = !_obscurePass),
            ),
          ),
          obscureText: _obscurePass,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "ENTRAR",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        TextField(
          controller: _nameRegCtrl,
          decoration: const InputDecoration(
            labelText: "Nombre completo",
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailRegCtrl,
          decoration: const InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passRegCtrl,
          decoration: const InputDecoration(
            labelText: "Contraseña",
            prefixIcon: Icon(Icons.lock_outline),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    "CREAR CUENTA",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
