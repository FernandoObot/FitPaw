import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'front_home_stub_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

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
                  const _LoginField(hint: 'Telefono', icon: Icons.phone_outlined),
                  SizedBox(height: 12 * scale),
                  const _LoginField(hint: 'Contrasena', icon: Icons.lock_outline_rounded, obscure: true),
                  SizedBox(height: 10 * scale),
                  Text('Olvidaste tu contrasena?', style: TextStyle(fontSize: Responsive.fs(context, 12), color: AppColors.textSecondary, decoration: TextDecoration.underline)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const FrontHomeStubScreen()));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        icon: const Icon(Icons.login_rounded, color: Colors.white),
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
  const _LoginField({required this.hint, required this.icon, this.obscure = false});

  final String hint;
  final IconData icon;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
