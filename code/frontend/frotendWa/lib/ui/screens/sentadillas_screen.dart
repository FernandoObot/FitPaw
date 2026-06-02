import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/workout_schedule_service.dart';
import 'training_schedule_screen.dart';
import '../widgets/responsive.dart';

class SentadillasScreen extends StatefulWidget {
  final DateTime selectedDate;

  const SentadillasScreen({super.key, required this.selectedDate});

  @override
  State<SentadillasScreen> createState() => _SentadillasScreenState();
}

class _SentadillasScreenState extends State<SentadillasScreen> {
  final WorkoutScheduleService _scheduleService = WorkoutScheduleService(
    ApiClient(),
  );
  late int _selectedHour;
  late int _selectedMinute;
  late String _selectedPeriod;
  bool _isSaving = false;

  String _selectedDifficulty = 'Media';
  String _selectedRepetitions = '8 - 12';
  String _selectedWeight = '12 kg';

  static const List<String> _weekdayLabels = [
    'Lun',
    'Mar',
    'Mier',
    'Juev',
    'Vier',
    'Sab',
    'Dom',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedHour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    _selectedMinute = now.minute;
    _selectedPeriod = now.hour >= 12 ? 'PM' : 'AM';
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isCompact = screenWidth < 360;
    final double horizontalPadding = isCompact ? 14 * scale : 18 * scale;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.phoneWidth(context),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12 * scale,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20 * scale),
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 36 * scale,
                            height: 36 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10 * scale),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.textPrimary,
                              size: 20 * scale,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Horario por dia',
                              style: TextStyle(
                                fontSize: Responsive.fs(
                                  context,
                                  isCompact ? 17 : 18,
                                ),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 6 * scale,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 6 * scale),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.textSecondary,
                              size: 18 * scale,
                            ),
                            SizedBox(width: 8 * scale),
                            Text(
                              _weekdayLabels[(widget.selectedDate.weekday - 1)
                                  .clamp(0, 6)],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12 * scale),
                        Text(
                          'Hora',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 14),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: _showTimePickerSheet,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final bool ultraCompact =
                                  constraints.maxWidth < 320;
                              final double gap = ultraCompact
                                  ? 6 * scale
                                  : 8 * scale;
                              return Row(
                                children: [
                                  Expanded(
                                    child: _TimeColumn(
                                      topValue: (_selectedHour - 1)
                                          .clamp(1, 12)
                                          .toString(),
                                      selectedValue: _selectedHour.toString(),
                                      bottomValue: (_selectedHour + 1)
                                          .clamp(1, 12)
                                          .toString(),
                                      compact: isCompact,
                                    ),
                                  ),
                                  SizedBox(width: gap),
                                  Expanded(
                                    child: _TimeColumn(
                                      topValue:
                                          (_selectedMinute == 0
                                                  ? 59
                                                  : _selectedMinute - 1)
                                              .toString()
                                              .padLeft(2, '0'),
                                      selectedValue: _selectedMinute
                                          .toString()
                                          .padLeft(2, '0'),
                                      bottomValue:
                                          (_selectedMinute == 59
                                                  ? 0
                                                  : _selectedMinute + 1)
                                              .toString()
                                              .padLeft(2, '0'),
                                      compact: isCompact,
                                    ),
                                  ),
                                  SizedBox(width: gap),
                                  Expanded(
                                    child: _TimeColumn(
                                      topValue: _selectedPeriod == 'AM'
                                          ? 'PM'
                                          : 'AM',
                                      selectedValue: _selectedPeriod,
                                      bottomValue: '',
                                      compact: isCompact,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        Text(
                          'Detalles de rutina',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 16),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _DetailCard(
                          icon: Icons.swap_vert,
                          title: 'Dificultad',
                          subtitle: _selectedDifficulty,
                          compact: isCompact,
                          onTap: () => _showOptionSheet(
                            title: 'Dificultad',
                            current: _selectedDifficulty,
                            options: const ['Normal', 'Media', 'Baja'],
                            onSelect: (value) =>
                                setState(() => _selectedDifficulty = value),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _DetailCard(
                          icon: Icons.bar_chart,
                          title: 'Ajustar repeticiones',
                          subtitle: _selectedRepetitions,
                          compact: isCompact,
                          onTap: () => _showOptionSheet(
                            title: 'Ajustar repeticiones',
                            current: _selectedRepetitions,
                            options: const [
                              '6 - 8',
                              '8 - 12',
                              '12 - 15',
                              '15 - 20',
                            ],
                            onSelect: (value) =>
                                setState(() => _selectedRepetitions = value),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _DetailCard(
                          icon: Icons.monitor_weight,
                          title: 'Ajustar pesos',
                          subtitle: _selectedWeight,
                          compact: isCompact,
                          onTap: () => _showOptionSheet(
                            title: 'Ajustar pesos',
                            current: _selectedWeight,
                            options: const [
                              '5 kg',
                              '8 kg',
                              '10 kg',
                              '12 kg',
                              '15 kg',
                              '20 kg',
                            ],
                            onSelect: (value) =>
                                setState(() => _selectedWeight = value),
                          ),
                        ),
                        SizedBox(height: 28 * scale),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    6 * scale,
                    horizontalPadding,
                    18 * scale,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: isCompact ? 54 * scale : 56 * scale,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _guardarPlan,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28 * scale),
                        ),
                        elevation: 6 * scale,
                        shadowColor: AppColors.blueSecondary.withValues(
                          alpha: 0.25,
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(28 * scale),
                        ),
                        child: Center(
                          child: _isSaving
                              ? SizedBox(
                                  width: 22 * scale,
                                  height: 22 * scale,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Guardar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: Responsive.fs(
                                      context,
                                      isCompact ? 15 : 16,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
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

  Future<void> _guardarPlan() async {
    setState(() => _isSaving = true);
    try {
      // Convertir hora de 12h a 24h
      int hour24 = _selectedHour;
      if (_selectedPeriod == 'PM' && _selectedHour != 12) {
        hour24 += 12;
      } else if (_selectedPeriod == 'AM' && _selectedHour == 12) {
        hour24 = 0;
      }

      // VALIDACIÓN: Verificar conflictos antes de guardar
      final String? conflictError = await _scheduleService
          .checkExerciseConflicts(
            nombreEjercicio: 'Sentadillas',
            fecha: widget.selectedDate,
            hora: hour24,
          );

      if (conflictError != null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(conflictError),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() => _isSaving = false);
        return; // No guardar si hay conflicto
      }

      // Extraer repeticiones (ej. "8 - 12" → tomar máximo)
      int repeticiones;
      try {
        repeticiones = int.parse(
          RegExp(r'\d+').firstMatch(_selectedRepetitions)!.group(0)!,
        );
      } catch (e) {
        repeticiones = 0; // fallback si no encuentra número
      }

      // Extraer peso (de "12 kg" → 12.0)
      double peso = double.parse(_selectedWeight.split(' ')[0]);

      // Llamada al servicio
      await _scheduleService.saveFuerzaExercise(
        nombre: 'Sentadillas',
        grupoMuscular: 'Piernas',
        dificultad: _selectedDifficulty,
        repeticiones: repeticiones,
        peso: peso,
        fecha: widget.selectedDate,
        hora: hour24,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => TrainingScheduleScreen(
            exerciseTitle: 'Sentadillas',
            exerciseSubtitle: '3 series de 15 reps',
            exerciseIcon: Icons.directions_run_rounded,
            initialSelectedDate: widget.selectedDate,
          ),
        ),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo guardar: $error')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showTimePickerSheet() {
    // Generar lista de horas permitidas: 6 AM a 8 PM (6 a 20 en formato 24h)
    final List<String> hours = [];
    for (int i = 6; i <= 20; i++) {
      int hour12 = i > 12 ? i - 12 : (i == 12 ? 12 : i);
      String period = i >= 12 ? 'PM' : 'AM';
      hours.add('$hour12 $period');
    }
    final List<String> minutes = List.generate(
      60,
      (i) => i.toString().padLeft(2, '0'),
    );

    // Convertir hora actual (12h con período) a índice en la lista 6-20
    int currentHour24h = _selectedHour;
    if (_selectedPeriod == 'PM' && _selectedHour != 12) {
      currentHour24h += 12;
    } else if (_selectedPeriod == 'AM' && _selectedHour == 12) {
      currentHour24h = 0; // 12 AM = 0
    }
    // Asegurar que esté en rango 6-20
    currentHour24h = currentHour24h.clamp(6, 20);
    int selectedHourIndex = currentHour24h - 6; // índice 0-14

    int selectedMinute = _selectedMinute;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
      builder: (context) {
        final double scale = Responsive.scale(context);
        final double maxHeight = MediaQuery.sizeOf(context).height * 0.5;
        return Center(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SizedBox(
                height: maxHeight.clamp(240.0, 340.0),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16 * scale,
                        vertical: 8 * scale,
                      ),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // Convertir índice (0-14) a hora 24h (6-20)
                              int hour24h = selectedHourIndex + 6;
                              // Convertir a formato 12h con período
                              int hour12 = hour24h > 12
                                  ? hour24h - 12
                                  : (hour24h == 0 ? 12 : hour24h);
                              String period = hour24h >= 12 ? 'PM' : 'AM';

                              setState(() {
                                _selectedHour = hour12;
                                _selectedMinute = selectedMinute;
                                _selectedPeriod = period;
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Listo'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 36 * scale,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedHourIndex,
                              ),
                              onSelectedItemChanged: (index) => setModalState(
                                () => selectedHourIndex = index,
                              ),
                              children: hours
                                  .map(
                                    (value) => Center(
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: Responsive.fs(context, 18),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 36 * scale,
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedMinute,
                              ),
                              onSelectedItemChanged: (index) =>
                                  setModalState(() => selectedMinute = index),
                              children: minutes
                                  .map(
                                    (value) => Center(
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          fontSize: Responsive.fs(context, 18),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showOptionSheet({
    required String title,
    required String current,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
      builder: (context) {
        final double scale = Responsive.scale(context);
        final double maxHeight = MediaQuery.sizeOf(context).height * 0.55;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                14 * scale,
                16 * scale,
                20 * scale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: Responsive.fs(context, 17),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: options
                          .map(
                            (option) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(option),
                              trailing: option == current
                                  ? Icon(
                                      Icons.check_rounded,
                                      color: AppColors.mintPrimary,
                                    )
                                  : null,
                              onTap: () {
                                onSelect(option);
                                Navigator.pop(context);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.topValue,
    required this.selectedValue,
    required this.bottomValue,
    required this.compact,
  });

  final String topValue;
  final String selectedValue;
  final String bottomValue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Column(
      children: [
        Text(
          topValue,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: (compact ? 11 : 12) * scale,
          ),
        ),
        SizedBox(height: 6 * scale),
        Container(
          height: (compact ? 48 : 52) * scale,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                selectedValue,
                style: TextStyle(
                  fontSize: (compact ? 18 : 20) * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 6 * scale),
        SizedBox(
          height: 16 * scale,
          child: Text(
            bottomValue,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: (compact ? 11 : 12) * scale,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 14 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F4F7),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Row(
            children: [
              Container(
                width: (compact ? 40 : 44) * scale,
                height: (compact ? 40 : 44) * scale,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textSecondary,
                  size: (compact ? 18 : 20) * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: Responsive.fs(context, compact ? 15 : 16),
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: Responsive.fs(context, compact ? 12 : 13),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
