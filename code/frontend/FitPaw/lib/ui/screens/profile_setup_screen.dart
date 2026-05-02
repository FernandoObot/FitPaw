import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'goal_picker_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24 * scale, 26 * scale, 24 * scale, 20 * scale),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - (46 * scale)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 278 * scale,
                          width: double.infinity,
                          child: Center(
                            child: Image.asset(
                              'assets/images/profile_setup.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28 * scale),
                                    gradient: AppColors.primaryGradient,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Icon(Icons.self_improvement_rounded, size: 118 * scale, color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        Text('Completa tu perfil', style: TextStyle(fontSize: Responsive.fs(context, 24), fontWeight: FontWeight.w700)),
                        SizedBox(height: 8 * scale),
                        Text('Nos ayudara a conocer mas sobre ti', style: TextStyle(fontSize: Responsive.fs(context, 13), color: AppColors.textSecondary)),
                        SizedBox(height: 20 * scale),
                        const _ProfileField(hint: 'Selecciona tu genero', icon: Icons.person_2_outlined, hasDropdown: true),
                        SizedBox(height: 12 * scale),
                        const _ProfileField(hint: 'Ano de nacimiento', icon: Icons.calendar_month_outlined),
                        SizedBox(height: 12 * scale),
                        _TwoMetricRow(scale: scale, left: 'Peso', rightLabel: 'KG', leftIcon: Icons.monitor_weight_outlined),
                        SizedBox(height: 12 * scale),
                        _TwoMetricRow(scale: scale, left: 'Estatura', rightLabel: 'CM', leftIcon: Icons.height_outlined),
                        SizedBox(height: 24 * scale),
                        SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const GoalPickerScreen()));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Siguiente', style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 18), fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.hint, required this.icon, this.hasDropdown = false});

  final String hint;
  final IconData icon;
  final bool hasDropdown;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: hasDropdown,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.faintText, fontSize: Responsive.fs(context, 13)),
        prefixIcon: Icon(icon, color: AppColors.faintText, size: 20),
        suffixIcon: hasDropdown ? const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.faintText) : null,
      ),
    );
  }
}

class _TwoMetricRow extends StatelessWidget {
  const _TwoMetricRow({required this.scale, required this.left, required this.rightLabel, required this.leftIcon});

  final double scale;
  final String left;
  final String rightLabel;
  final IconData leftIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ProfileField(hint: left, icon: leftIcon)),
        SizedBox(width: 10 * scale),
        Container(
          width: 56 * scale,
          height: 50 * scale,
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12 * scale)),
          alignment: Alignment.center,
          child: Text(rightLabel, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: Responsive.fs(context, 13))),
        ),
      ],
    );
  }
}
