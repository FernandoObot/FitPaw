import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 8 * scale),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(width: 36 * scale, height: 36 * scale, child: Icon(Icons.chevron_left_rounded, size: 22 * scale, color: AppColors.textPrimary)),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text('Progreso personal', style: TextStyle(color: AppColors.textPrimary, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                ),
                SizedBox(height: 18 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Resumen semanal', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: Responsive.fs(context, 14))),
                            SizedBox(height: 12 * scale),
                            Text('Aquí irían gráficos y métricas de progreso.', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 12))),
                          ],
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Historial de entrenamientos', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: Responsive.fs(context, 14))),
                            SizedBox(height: 12 * scale),
                            Text('Lista de sesiones previas y resultados.', style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 12))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
