import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  int _selectedActivityIndex = 0;
  bool _animateBars = false;

  final List<double> _weekValues = [0.35, 0.72, 0.48, 0.62, 0.85, 0.38, 0.68];
  final List<String> _weekLabels = ['Lun', 'Mar', 'Mierc', 'Juev', 'Vier', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() => _animateBars = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20 * scale, 12 * scale, 20 * scale, 24 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () => Navigator.pop(context),
                          child: SizedBox(
                            width: 36 * scale,
                            height: 36 * scale,
                            child: Icon(
                              Icons.chevron_left_rounded,
                              color: AppColors.textPrimary,
                              size: 22 * scale,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Historial de actividades',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: Responsive.fs(context, 18),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Progreso de actividades',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  _ChartCard(
                    values: _weekValues,
                    labels: _weekLabels,
                    animateBars: _animateBars,
                  ),
                  SizedBox(height: 18 * scale),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Actividades mas recientes',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  _ActivityTile(
                    title: 'Programa de cardio',
                    subtitle: 'Hace 3 minutos',
                    icon: Icons.favorite_rounded,
                    isSelected: _selectedActivityIndex == 0,
                    onTap: () => setState(() => _selectedActivityIndex = 0),
                  ),
                  SizedBox(height: 12 * scale),
                  _ActivityTile(
                    title: 'Programa de cuerpo bajo',
                    subtitle: 'Hace 1 hora',
                    icon: Icons.fitness_center_rounded,
                    isSelected: _selectedActivityIndex == 1,
                    onTap: () => setState(() => _selectedActivityIndex = 1),
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

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.values,
    required this.labels,
    required this.animateBars,
  });

  final List<double> values;
  final List<String> labels;
  final bool animateBars;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 140 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(values.length, (index) {
                final double targetHeight = 100 * scale * values[index];
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: animateBars ? targetHeight : 8 * scale,
                        width: 18 * scale,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fs(context, 10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18 * scale),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF2F2) : const Color(0xFFF7EFEF),
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: isSelected ? AppColors.mintPrimary.withValues(alpha: 0.5) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F2EE),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.mintPrimary, size: 22 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: Responsive.fs(context, 13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.fs(context, 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
