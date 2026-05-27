import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/styles.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// LOGIN
  final _emailLoginCtrl = TextEditingController();
  final _passLoginCtrl = TextEditingController();

  /// REGISTER
  final _emailRegCtrl = TextEditingController();
  final _passRegCtrl = TextEditingController();
  final _nameRegCtrl = TextEditingController();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureRegisterPass = true;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
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

  /// =====================================
  /// LOGIN
  /// =====================================
  Future<void> _handleLogin() async {
    if (_isLoading) return;

    if (_emailLoginCtrl.text.trim().isEmpty ||
        _passLoginCtrl.text.trim().isEmpty) {
      _showError("Complete todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    final errorMsg = await ref
        .read(authProvider.notifier)
        .login(_emailLoginCtrl.text.trim(), _passLoginCtrl.text.trim());

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (errorMsg != null) {
      _showError(errorMsg);
    }

    /// No navegar aquí
    /// SessionGateScreen se encargará automáticamente
  }

  /// =====================================
  /// REGISTER
  /// =====================================
  Future<void> _handleRegister() async {
    if (_isLoading) return;

    if (_emailRegCtrl.text.trim().isEmpty ||
        _passRegCtrl.text.trim().isEmpty ||
        _nameRegCtrl.text.trim().isEmpty) {
      _showError("Complete todos los campos");
      return;
    }

    if (_passRegCtrl.text.length < 6) {
      _showError("La contraseña debe tener mínimo 6 caracteres");
      return;
    }

    setState(() => _isLoading = true);

    final errorMsg = await ref
        .read(authProvider.notifier)
        .register(
          email: _emailRegCtrl.text.trim(),
          pass: _passRegCtrl.text.trim(),
          nombre: _nameRegCtrl.text.trim(),
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (errorMsg != null) {
      _showError(errorMsg);
      return;
    }

    _showSuccess("Cuenta creada correctamente");

    _emailRegCtrl.clear();
    _passRegCtrl.clear();
    _nameRegCtrl.clear();

    /// Volver a login
    _tabController.animateTo(0);
  }

  /// =====================================
  /// SNACKS
  /// =====================================
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
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
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
                        height: 320,
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

  /// =====================================
  /// LOGIN FORM
  /// =====================================
  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailLoginCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Correo electrónico",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _passLoginCtrl,
          obscureText: _obscurePass,
          decoration: InputDecoration(
            labelText: "Contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePass ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePass = !_obscurePass;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(),
                  )
                : const Text('ENTRAR'),
          ),
        ),
      ],
    );
  }

  /// =====================================
  /// REGISTER FORM
  /// =====================================
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
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Correo",
            prefixIcon: Icon(Icons.email_outlined),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _passRegCtrl,
          obscureText: _obscureRegisterPass,
          decoration: InputDecoration(
            labelText: "Contraseña",
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureRegisterPass ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureRegisterPass = !_obscureRegisterPass;
                });
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleRegister,
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(),
                  )
                : const Text('CREAR CUENTA'),
          ),
        ),
      ],
    );
  }
}
