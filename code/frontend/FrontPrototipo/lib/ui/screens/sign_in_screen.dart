import 'package:flutter/material.dart';

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
    if (telefonoController.text.isEmpty || contrasenaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await authService.login(
        telefono: telefonoController.text,
        password: contrasenaController.text,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const FrontHomeStubScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 28 * scale, 24 * scale, 20 * scale),
              child: Column(
                children: [
                  SizedBox(height: 20 * scale),
                  Text('Hola,', style: TextStyle(fontSize: Responsive.fs(context, 24), color: AppColors.textSecondary)),
                  Text('Bienvenido de vuelta', style: TextStyle(fontSize: Responsive.fs(context, 34), fontWeight: FontWeight.w700)),
                  SizedBox(height: 26 * scale),
                  _LoginField(
                    controller: telefonoController,
                    hint: 'Telefono',
                    icon: Icons.phone_outlined,
                  ),
                  SizedBox(height: 12 * scale),
                  _LoginField(
                    controller: contrasenaController,
                    hint: 'Contrasena',
                    icon: Icons.lock_outline_rounded,
                    obscure: true,
                  ),
                  SizedBox(height: 10 * scale),
                  Text('Olvidaste tu contrasena?', style: TextStyle(fontSize: Responsive.fs(context, 12), color: AppColors.textSecondary, decoration: TextDecoration.underline)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _iniciarSesion,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        icon: isLoading
                            ? SizedBox(
                                height: 24 * scale,
                                width: 24 * scale,
                                child: const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.login_rounded, color: Colors.white),
                        label: Text('Iniciar sesion', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SignUpScreen()));
                    },
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: Responsive.fs(context, 13), color: AppColors.textPrimary),
                        children: [
                          const TextSpan(text: 'No tienes una cuenta? '),
                          TextSpan(text: 'Registrate', style: TextStyle(color: AppColors.blueSecondary, fontWeight: FontWeight.w600)),
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

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.controller,
  });

  final String hint;
  final IconData icon;
  final bool obscure;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.faintText, fontSize: Responsive.fs(context, 13)),
        prefixIcon: Icon(icon, color: AppColors.faintText, size: 20),
        suffixIcon: obscure ? const Icon(Icons.visibility_off_outlined, color: AppColors.faintText, size: 20) : null,
      ),
    );
  }
}
