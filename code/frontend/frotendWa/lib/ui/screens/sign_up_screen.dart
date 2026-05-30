import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  bool _isValidUsername(String username) {
    return RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ]{1,16}$').hasMatch(username);
  }

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

    if (!_isValidUsername(nombreCompleto)) {
      _showSnackBar('El nombre de usuario debe tener máximo 16 letras, sin números ni símbolos.');
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      _showSnackBar('El teléfono debe tener exactamente 10 dígitos.');
      return;
    }

    if (!_isValidPassword(password)) {
      _showSnackBar('La contraseña debe tener mínimo 8 caracteres, una letra y un número.');
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
                    hint: 'Nombre de usuario',
                    icon: Icons.person_outline_rounded,
                    maxLength: 16,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ]')),
                    ],
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

class _RegField extends StatefulWidget {
  const _RegField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLength,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_RegField> createState() => _RegFieldState();
}

class _RegFieldState extends State<_RegField> {
  late bool _hideText;

  @override
  void initState() {
    super.initState();
    _hideText = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure && _hideText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hint,
        hintStyle: TextStyle(color: AppColors.faintText, fontSize: Responsive.fs(context, 13)),
        prefixIcon: Icon(widget.icon, color: AppColors.faintText, size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hideText ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => _hideText = !_hideText),
                icon: Icon(
                  _hideText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.faintText,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
