import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/workout_schedule_service.dart';
import '../widgets/responsive.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  final WorkoutScheduleService _scheduleService = WorkoutScheduleService(ApiClient());
  int _selectedActivityIndex = 0;
  bool _animateBars = false;
  bool _isLoading = true;
  String? _errorMessage;

  final List<int> _weekCounts = List<int>.filled(7, 0);
  final List<_RecentActivity> _recentActivities = [];
  final List<String> _weekLabels = ['Lun', 'Mar', 'Mierc', 'Juev', 'Vier', 'Sab', 'Dom'];

  @override
  void initState() {
    super.initState();
    _loadActivityHistory();
  }

  Future<void> _loadActivityHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _animateBars = false;
    });

    final today = DateTime.now();
    final monday = DateTime(today.year, today.month, today.day).subtract(Duration(days: today.weekday - 1));
    final nextCounts = List<int>.filled(7, 0);
    final nextRecent = <_RecentActivity>[];

    try {
      for (int index = 0; index < 7; index++) {
        final date = monday.add(Duration(days: index));
        final exercises = await _scheduleService.loadExercisesForDate(fecha: date);
        final completed = exercises.where((exercise) => exercise['completado'] == true).toList();
        nextCounts[index] = completed.length.clamp(0, 4);

        for (final exercise in completed) {
          nextRecent.add(_RecentActivity.fromExercise(exercise, date));
        }
      }

      nextRecent.sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.hour.compareTo(a.hour);
      });

      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _weekCounts.length; i++) {
          _weekCounts[i] = nextCounts[i];
        }
        _recentActivities
          ..clear()
          ..addAll(nextRecent.take(8));
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _animateBars = true);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No se pudo cargar el historial';
      });
    }
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
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    _EmptyState(message: _errorMessage!)
                  else
                    _ChartCard(
                      counts: _weekCounts,
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
                  if (!_isLoading && _recentActivities.isEmpty)
                    const _EmptyState(message: 'Aun no hay ejercicios completados esta semana')
                  else
                    ...List.generate(_recentActivities.length, (index) {
                      final activity = _recentActivities[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12 * scale),
                        child: _ActivityTile(
                          title: activity.title,
                          subtitle: activity.subtitle,
                          icon: activity.icon,
                          detail: activity.detail,
                          isSelected: _selectedActivityIndex == index,
                          onTap: () => setState(() => _selectedActivityIndex = index),
                        ),
                      );
                    }),
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
    required this.counts,
    required this.labels,
    required this.animateBars,
  });

  final List<int> counts;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4 * scale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '4',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.fs(context, 10),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Ejercicios completados por dia',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: Responsive.fs(context, 10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 140 * scale,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(counts.length, (index) {
                final int count = counts[index].clamp(0, 4);
                final double targetHeight = (12 + (88 * (count / 4))) * scale;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$count',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fs(context, 10),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
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
          Padding(
            padding: EdgeInsets.only(left: 4 * scale),
            child: Text(
              '0',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.fs(context, 10),
                fontWeight: FontWeight.w700,
              ),
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
    required this.detail,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String detail;
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
                    if (detail.isNotEmpty) ...[
                      SizedBox(height: 3 * scale),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fs(context, 10),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: Responsive.fs(context, 12),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecentActivity {
  const _RecentActivity({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.icon,
    required this.date,
    required this.hour,
  });

  final String title;
  final String subtitle;
  final String detail;
  final IconData icon;
  final DateTime date;
  final int hour;

  factory _RecentActivity.fromExercise(Map<String, dynamic> exercise, DateTime date) {
    final String title = (exercise['nombre'] as String?) ?? 'Ejercicio';
    final String tipo = (exercise['tipo'] as String?) ?? '';
    final int hour = exercise['hora'] is num ? (exercise['hora'] as num).toInt() : 0;
    final String subtitle = '${_dayLabel(date)} · ${_hourLabel(hour)}';
    final String detail = _detailFor(exercise);
    final IconData icon = tipo == 'cardio' ? Icons.favorite_rounded : Icons.fitness_center_rounded;

    return _RecentActivity(
      title: title,
      subtitle: subtitle,
      detail: detail,
      icon: icon,
      date: date,
      hour: hour,
    );
  }

  static String _detailFor(Map<String, dynamic> exercise) {
    final String tipo = (exercise['tipo'] as String?) ?? '';
    if (tipo == 'cardio') {
      final minutos = exercise['tiempo_minutos'];
      return minutos == null ? 'Cardio completado' : '$minutos minutos';
    }

    final reps = exercise['repeticiones'];
    final peso = exercise['peso'];
    final parts = <String>[];
    if (reps != null) parts.add('$reps reps');
    if (peso != null) parts.add('$peso kg');
    return parts.isEmpty ? 'Fuerza completada' : parts.join(', ');
  }

  static String _dayLabel(DateTime date) {
    const names = ['Lun', 'Mar', 'Mierc', 'Juev', 'Vier', 'Sab', 'Dom'];
    return names[date.weekday - 1];
  }

  static String _hourLabel(int hour) {
    if (hour <= 0) return 'Sin hora';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return '$hour12:00 $period';
  }
}
