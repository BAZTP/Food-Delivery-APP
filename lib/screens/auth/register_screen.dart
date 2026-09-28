import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/forgot_password_modal.dart';
import '../main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isCheckingEmail = false;
  bool _isEmailTaken = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  void _onEmailFocusChange() {
    if (!_emailFocusNode.hasFocus) {
      _verifyEmail(_emailController.text.trim());
    }
  }

  void _onEmailChanged(String val) {
    if (_isEmailTaken) {
      setState(() => _isEmailTaken = false);
    }
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      if (val.contains('@') && val.contains('.')) {
        _verifyEmail(val.trim());
      }
    });
  }

  Future<void> _verifyEmail(String email) async {
    if (email.isEmpty || !email.contains('@')) return;

    setState(() => _isCheckingEmail = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exists = await auth.checkEmailExists(email);

    if (mounted) {
      setState(() {
        _isCheckingEmail = false;
        _isEmailTaken = exists;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showEmailAlreadyRegisteredDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.account_circle_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 10),
            Text('Correo ya registrado', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'El correo "$email" ya se encuentra registrado en QuickFood.\n\n¿Deseas iniciar sesión con tu cuenta o restablecer tu contraseña si la olvidaste?',
          style: const TextStyle(fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cambiar correo'),
          ),
          OutlinedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ForgotPasswordModal.show(context, initialEmail: email);
            },
            child: const Text('Restablecer clave'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Vuelve a la pantalla de login
            },
            child: const Text('Iniciar Sesión'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Verificación proactiva de correo duplicado
    final alreadyExists = await auth.checkEmailExists(email);
    if (alreadyExists) {
      if (!mounted) return;
      setState(() {
        _isEmailTaken = true;
        _isLoading = false;
      });
      _showEmailAlreadyRegisteredDialog(email);
      return;
    }

    final success = await auth.register(
      name: _nameController.text.trim(),
      email: email,
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Ingreso directo sin pantallas de bloqueo por verificación
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } else {
      if (auth.errorMessage?.contains('ya está registrado') == true ||
          auth.errorMessage?.contains('ya se encuentra registrado') == true) {
        setState(() => _isEmailTaken = true);
        _showEmailAlreadyRegisteredDialog(email);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Error al registrar la cuenta'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Únete a QuickFood 🍕',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Crea una cuenta para pedir en segundos',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 24),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre y apellido',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu nombre';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _onEmailChanged,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: _isCheckingEmail
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _isEmailTaken
                            ? const Icon(Icons.warning_amber_rounded, color: Colors.orange)
                            : null,
                  ),
                  validator: (val) {
                    if (val == null || !val.contains('@')) return 'Ingresa un correo válido';
                    if (_isEmailTaken) return 'Este correo ya está registrado';
                    return null;
                  },
                ),

                // Inline Warning if Email is taken
                if (_isEmailTaken) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Este correo ya tiene una cuenta en QuickFood.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  ForgotPasswordModal.show(
                                    context,
                                    initialEmail: _emailController.text.trim(),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                child: const Text('Recuperar Clave', style: TextStyle(fontSize: 12)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Número de teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Ingresa tu teléfono';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Registrarme'),
                  ),
                ),

                const SizedBox(height: 16),

                // Already have account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes una cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
