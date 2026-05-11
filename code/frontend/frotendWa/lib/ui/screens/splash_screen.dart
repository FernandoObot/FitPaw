import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/main_button.dart';
import '../widgets/responsive.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double scale = Responsive.scale(context);
              final double logoSize = 132 * scale;

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: logoSize,
                          height: logoSize,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(34 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(Icons.pets_rounded, color: Colors.white, size: 64 * scale),
                        ),
                        SizedBox(height: 20 * scale),
                        Text(
                          'FitPaw',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: Responsive.fs(context, 44),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          'Entrena mejor, vive mejor',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: Responsive.fs(context, 16)),
                        ),
                        const Spacer(),
                        MainButton(
                          text: 'Get Started',
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (context) => const OnboardingScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24 * scale),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
