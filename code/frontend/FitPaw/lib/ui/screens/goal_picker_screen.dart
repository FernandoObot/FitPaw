import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'front_home_stub_screen.dart';

class GoalPickerScreen extends StatefulWidget {
  const GoalPickerScreen({super.key});

  @override
  State<GoalPickerScreen> createState() => _GoalPickerScreenState();
}

class _GoalPickerScreenState extends State<GoalPickerScreen> {
  final PageController _cards = PageController(viewportFraction: 0.82);

  final List<_GoalData> _goals = const [
    _GoalData(
      title: 'Ganar musculo',
      desc: 'Tengo un bajo porcentaje de grasa corporal y busco construir mas masa muscular.',
      icon: Icons.fitness_center_rounded,
    ),
    _GoalData(
      title: 'Definir y tonificar',
      desc: 'Me veo delgado pero me falta firmeza. Quiero ganar masa magra de forma estetica.',
      icon: Icons.accessibility_new_rounded,
    ),
    _GoalData(
      title: 'Perder grasa',
      desc: 'Busco eliminar el exceso de grasa corporal y ganar masa muscular para transformar mi cuerpo.',
      icon: Icons.directions_run_rounded,
    ),
  ];

  @override
  void dispose() {
    _cards.dispose();
    super.dispose();
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
              padding: EdgeInsets.fromLTRB(0, 22 * scale, 0, 20 * scale),
              child: Column(
                children: [
                  Text('Cual es tu meta?', style: TextStyle(fontSize: Responsive.fs(context, 36), fontWeight: FontWeight.w700)),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Nos ayudara a recomendarte el mejor programa para ti.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 12), height: 1.35),
                  ),
                  SizedBox(height: 20 * scale),
                  Expanded(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(width: 22 * scale, height: 240 * scale, decoration: BoxDecoration(color: const Color(0xFFD5F1F0), borderRadius: BorderRadius.circular(14 * scale))),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(width: 22 * scale, height: 240 * scale, decoration: BoxDecoration(color: const Color(0xFFD6F2D9), borderRadius: BorderRadius.circular(14 * scale))),
                        ),
                        PageView.builder(
                          controller: _cards,
                          itemCount: _goals.length,
                          itemBuilder: (context, i) => _GoalCard(data: _goals[i]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  SizedBox(
                    width: 300 * scale,
                    height: 56 * scale,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute<void>(builder: (_) => const FrontHomeStubScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                        child: Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.data});

  final _GoalData data;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(22 * scale),
          boxShadow: [
            BoxShadow(color: AppColors.blueSecondary.withValues(alpha: 0.22), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(22 * scale, 18 * scale, 22 * scale, 22 * scale),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(data.icon, size: 118 * scale, color: Colors.white),
                ),
              ),
              Text(data.title, textAlign: TextAlign.center, style: TextStyle(fontSize: Responsive.fs(context, 24), fontWeight: FontWeight.w700, color: Colors.white)),
              SizedBox(height: 10 * scale),
              Text(
                data.desc,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Responsive.fs(context, 12), color: Colors.white.withValues(alpha: 0.94), height: 1.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalData {
  const _GoalData({required this.title, required this.desc, required this.icon});

  final String title;
  final String desc;
  final IconData icon;
}
