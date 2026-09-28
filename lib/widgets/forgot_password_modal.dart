import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class ForgotPasswordModal extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordModal({
    super.key,
    this.initialEmail = '',
  });

  static Future<void> show(BuildContext context, {String initialEmail = ''}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ForgotPasswordModal(initialEmail: initialEmail),
    );
  }

  @override
  State<ForgotPasswordModal> createState() => _ForgotPasswordModalState();
}

class _ForgotPasswordModalState extends State<ForgotPasswordModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleDirectReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    final result = await auth.resetPasswordDirectly(
      email: email,
      newPassword: newPassword,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = result['success'] == true;
      _statusMessage = result['message'];
    });

    if (_isSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${_statusMessage ?? "Contraseña restablecida con éxito."}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    }
  }

  Future<void> _handleEmailLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _statusMessage = 'Por favor escribe un correo válido para enviarte el enlace.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.sendPasswordResetEmail(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isSuccess = result['success'] == true;
      _statusMessage = result['message'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Restablecer Clave',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Ingresa tu correo registrado y define tu nueva contraseña directamente.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 18),

              // Status Banner
              if (_statusMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess
                        ? AppColors.success.withOpacity(0.12)
                        : Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isSuccess
                          ? AppColors.success.withOpacity(0.4)
                          : Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _isSuccess ? AppColors.success : Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: _isSuccess ? AppColors.success : Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Email field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico registrado',
                  hintText: 'ejemplo@correo.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                  if (!val.contains('@')) return 'Ingresa un correo válido';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // New Password
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.length < 6) {
                    return 'La nueva contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              // Confirm New Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  hintText: 'Repite tu nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_clock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    ),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (val) {
                  if (val != _newPasswordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Main Reset Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleDirectReset,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Restablecer y Guardar Clave', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),

              const SizedBox(height: 10),

              // Option to send email link
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _handleEmailLink,
                  icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                  label: const Text(
                    'O enviar enlace de recuperación a mi correo',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
