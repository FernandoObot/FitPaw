import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import 'home_dashboard_screen.dart';
import '../widgets/responsive.dart';

class FrontHomeStubScreen extends StatelessWidget {
  const FrontHomeStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 24 * scale, 24 * scale, 22 * scale),
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    height: 332 * scale,
                    width: double.infinity,
                    child: Center(
                      child: Image.asset(
                        'assets/images/bienvenida.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.groups_2_rounded, size: 122 * scale, color: Colors.white);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 22 * scale),
                  Text('Bienvenido, Usuario', style: TextStyle(fontSize: Responsive.fs(context, 32), fontWeight: FontWeight.w700)),
                  SizedBox(height: 10 * scale),
                  Text(
                    'Ya estas preparado! Tu mascota te esta esperando para alcanzar tus metas juntos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: Responsive.fs(context, 13), color: AppColors.textSecondary, height: 1.4),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(builder: (_) => const HomeDashboardScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: Text('Ir al inicio', style: TextStyle(fontSize: Responsive.fs(context, 18), color: Colors.white, fontWeight: FontWeight.w700)),
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
