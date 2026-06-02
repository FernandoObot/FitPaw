import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../widgets/responsive.dart';
import 'front_home_stub_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late AuthService authService;
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authService = AuthService(ApiClient());
  }

  @override
  void dispose() {
    telefonoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final telefono = telefonoController.text.trim();
    final contrasena = contrasenaController.text;

    if (telefono.isEmpty || contrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El teléfono debe tener exactamente 10 dígitos.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await authService.login(
        telefono: telefono,
        password: contrasena,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const FrontHomeStubScreen(),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.phoneWidth(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24 * scale,
                28 * scale,
                24 * scale,
                20 * scale,
              ),
              child: Column(
                children: [
                  SizedBox(height: 20 * scale),
                  Text(
                    'Hola,',
                    style: TextStyle(
                      fontSize: Responsive.fs(context, 24),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      fontSize: Responsive.fs(context, 34),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 26 * scale),
                  _LoginField(
                    controller: telefonoController,
                    hint: 'Telefono',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  SizedBox(height: 12 * scale),
                  _LoginField(
                    controller: contrasenaController,
                    hint: 'Contrasena',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(30 * scale),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        icon: isLoading
                            ? SizedBox(
                                height: 24 * scale,
                                width: 24 * scale,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.login_rounded,
                                color: Colors.white,
                              ),
                        label: Text(
                          'Iniciar sesion',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.fs(context, 18),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: Responsive.fs(context, 13),
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'No tienes una cuenta? '),
                          TextSpan(
                            text: 'Registrate',
                            style: TextStyle(
                              color: AppColors.blueSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

class _LoginField extends StatefulWidget {
  const _LoginField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.maxLength,
    this.inputFormatters,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
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
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        counterText: '',
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: AppColors.faintText,
          fontSize: Responsive.fs(context, 13),
        ),
        prefixIcon: Icon(widget.icon, color: AppColors.faintText, size: 20),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hideText
                    ? 'Mostrar contraseña'
                    : 'Ocultar contraseña',
                onPressed: () => setState(() => _hideText = !_hideText),
                icon: Icon(
                  _hideText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.faintText,
                  size: 20,
                ),
              )
            : null,
      ),
    );
  }
}
