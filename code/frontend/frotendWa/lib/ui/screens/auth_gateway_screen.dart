import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/main_button.dart';
import '../widgets/responsive.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class AuthGatewayScreen extends StatelessWidget {
  const AuthGatewayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double scale = Responsive.scale(context);

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 18 * scale),
                    child: Column(
                      children: [
                        SizedBox(height: 20 * scale),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(36 * scale),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDFF2FF), Color(0xFFE8FFF4)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.fitness_center_rounded,
                                size: (constraints.maxWidth * 0.24).clamp(78.0, 102.0),
                                color: AppColors.deepNavy,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 28 * scale),
                        Text(
                          'Welcome To FitPaw',
                          style: TextStyle(fontSize: Responsive.fs(context, 30), fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12 * scale),
                        Text(
                          'Planifica tus metas, crea habitos y sigue tu progreso con una experiencia guiada.',
                          style: TextStyle(
                            fontSize: Responsive.fs(context, 15),
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 28 * scale),
                        MainButton(
                          text: 'Iniciar Sesion',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 12 * scale),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size.fromHeight(54 * scale),
                            side: const BorderSide(color: AppColors.deepNavy),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25 * scale)),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              color: AppColors.deepNavy,
                              fontSize: Responsive.fs(context, 16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
