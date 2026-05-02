import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'profile_setup_screen.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _terms = false;

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
                  const _RegField(hint: 'Nombre completo', icon: Icons.person_outline_rounded),
                  SizedBox(height: 12 * scale),
                  const _RegField(hint: 'Numero de telefono', icon: Icons.phone_outlined),
                  SizedBox(height: 12 * scale),
                  const _RegField(hint: 'Contrasena', icon: Icons.lock_outline_rounded, obscure: true),
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
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const ProfileSetupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: Text('Registrate', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
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
  const _RegField({required this.hint, required this.icon, this.obscure = false});

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
