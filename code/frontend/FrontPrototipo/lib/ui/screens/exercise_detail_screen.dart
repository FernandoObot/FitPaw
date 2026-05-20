import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'flexion_una_pierna_screen.dart';
import 'press_hombros_screen.dart';
import 'running_screen.dart';
import 'training_schedule_screen.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

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
                          child: Text(
                            title,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                ),
                SizedBox(height: 18 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18 * scale)),
                    child: Row(
                      children: [
                        Container(
                          width: 52 * scale,
                          height: 52 * scale,
                          decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.primaryGradient),
                          child: Icon(icon, color: Colors.white, size: 26 * scale),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TextStyle(color: AppColors.textPrimary, fontSize: Responsive.fs(context, 16), fontWeight: FontWeight.w700)),
                              SizedBox(height: 6 * scale),
                              Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 12))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18 * scale),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final Widget nextScreen = title == 'Correr'
                          ? RunningScreen(selectedDate: DateTime.now())
                          : title == 'Press de hombros'
                            ? PressHombrosScreen(selectedDate: DateTime.now())
                            : title == 'Flexion de una pierna (con pesas)'
                              ? FlexionUnaPiernaScreen(selectedDate: DateTime.now())
                              : TrainingScheduleScreen(exerciseTitle: title, exerciseSubtitle: subtitle, exerciseIcon: icon);

                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => nextScreen));
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
                        backgroundColor: AppColors.mintPrimary,
                      ),
                      child: Text('Horario por día', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 14), fontWeight: FontWeight.w700)),
                    ),
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
