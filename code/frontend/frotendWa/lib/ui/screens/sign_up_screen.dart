import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import '../../services/app_services.dart';
import 'profile_setup_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _terms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final nombreCompleto = _nameController.text.trim();
    final telefono = _phoneController.text.trim();
    final password = _passwordController.text;

    if (!_terms) {
      _showSnackBar('Debes aceptar la política de privacidad y términos.');
      return;
    }

    if (nombreCompleto.isEmpty || telefono.isEmpty || password.isEmpty) {
      _showSnackBar('Completa todos los campos.');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      _showSnackBar('El teléfono debe tener exactamente 10 dígitos.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registerResult = await authService.register(
        nombreCompleto: nombreCompleto,
        telefono: telefono,
        password: password,
      );

      if (registerResult['success'] != true) {
        _showSnackBar(registerResult['error']?.toString() ?? 'No se pudo registrar.');
        return;
      }

      final loginResult = await authService.login(
        telefono: telefono,
        password: password,
      );

      if (!mounted) return;

      if (loginResult['success'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
        );
      } else {
        _showSnackBar('Usuario creado, pero no se pudo iniciar sesión automáticamente.');
      }
    } catch (e) {
      _showSnackBar('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 28 * scale, 24 * scale, 20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('Hola,', style: TextStyle(fontSize: Responsive.fs(context, 24), color: AppColors.textSecondary)),
                  ),
                  Center(
                    child: Text('Crea una cuenta', style: TextStyle(fontSize: Responsive.fs(context, 36), fontWeight: FontWeight.w700)),
                  ),
                  SizedBox(height: 26 * scale),
                  _RegField(
                    controller: _nameController,
                    hint: 'Nombre completo',
                    icon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 12 * scale),
                  _RegField(
                    controller: _phoneController,
                    hint: 'Numero de telefono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  SizedBox(height: 12 * scale),
                  _RegField(
                    controller: _passwordController,
                    hint: 'Contrasena',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 16 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _terms,
                        activeColor: AppColors.mintPrimary,
                        onChanged: (value) => setState(() => _terms = value ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 4 * scale),
                          child: Text(
                            'Al continuar aceptas nuestra Politica de Privacidad y Terminos de uso',
                            style: TextStyle(fontSize: Responsive.fs(context, 11), color: AppColors.textSecondary, height: 1.35),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Text('Registrate', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: Responsive.fs(context, 13), color: AppColors.textPrimary),
                          children: [
                            const TextSpan(text: 'Ya tienes una cuenta? '),
                            TextSpan(
                              text: 'Inicia sesion',
                              style: TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegField extends StatelessWidget {
  const _RegField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.faintText, fontSize: Responsive.fs(context, 13)),
        prefixIcon: Icon(icon, color: AppColors.faintText, size: 20),
        suffixIcon: obscure ? const Icon(Icons.visibility_off_outlined, color: AppColors.faintText, size: 20) : null,
      ),
    );
  }
}
