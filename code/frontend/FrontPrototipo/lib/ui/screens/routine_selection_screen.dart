import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';

class RoutineSelectionScreen extends StatelessWidget {
  const RoutineSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 * scale : 24 * scale),
              child: Column(
                children: [
                  SizedBox(height: 8 * scale),
                  Row(
                    children: [
                      Material(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 36 * scale,
                            height: 36 * scale,
                            child: Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary, size: 24 * scale),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Rutina',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.fs(context, 18),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                  SizedBox(height: 22 * scale),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        _RoutineCard(
                          title: 'Cardio',
                          subtitle: '11 Ejercicios | 32mins',
                          buttonLabel: 'Ver más',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDDFBE2), Color(0xFFB5F4EE)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          icon: Icons.favorite_border_rounded,
                          iconColor: const Color(0xFF10B981),
                          onTap: () => Navigator.pop(context, 'Cardio'),
                        ),
                        SizedBox(height: 14 * scale),
                        _RoutineCard(
                          title: 'Cuerpo bajo',
                          subtitle: '12 Ejercicios | 40mins',
                          buttonLabel: 'Ver más',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE2FBE8), Color(0xFFB7F2ED)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          icon: Icons.directions_run_rounded,
                          iconColor: const Color(0xFFEF4444),
                          onTap: () => Navigator.pop(context, 'Cuerpo bajo'),
                        ),
                        SizedBox(height: 14 * scale),
                        _RoutineCard(
                          title: 'Abdomen',
                          subtitle: '14 Ejercicios | 20mins',
                          buttonLabel: 'Ver más',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF0F7FF), Color(0xFFC8F4E6)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          icon: Icons.self_improvement_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          onTap: () => Navigator.pop(context, 'Abdomen'),
                        ),
                        SizedBox(height: 14 * scale),
                        _RoutineCard(
                          title: 'Agregar un ejercicio',
                          subtitle: '',
                          buttonLabel: 'Ajustar',
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE5FBE4), Color(0xFFB7F2F0)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          icon: Icons.add_circle_outline_rounded,
                          iconColor: const Color(0xFF06B6D4),
                          onTap: () => Navigator.pop(context, 'Agregar un ejercicio'),
                        ),
                        SizedBox(height: 18 * scale),
                      ],
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

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.gradient,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final LinearGradient gradient;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 142 * scale,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(26 * scale),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(right: 20 * scale),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(18 * scale, 20 * scale, 0, 20 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: Responsive.fs(context, 16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 6 * scale),
                            if (subtitle.isNotEmpty)
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: const Color(0xFFB4B1C1),
                                  fontSize: Responsive.fs(context, 12),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            SizedBox(height: 14 * scale),
                            GestureDetector(
                              onTap: onTap,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 9 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  buttonLabel,
                                  style: TextStyle(
                                    color: AppColors.mintPrimary,
                                    fontSize: Responsive.fs(context, 12),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 128 * scale,
                      child: Center(
                        child: Container(
                          width: 108 * scale,
                          height: 108 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 54 * scale,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
