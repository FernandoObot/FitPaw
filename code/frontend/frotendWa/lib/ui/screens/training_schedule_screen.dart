import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../core/app_colors.dart';
import '../../services/api_client.dart';
import '../../services/workout_schedule_service.dart';
import '../../services/racha_service.dart';
import 'routine_selection_screen.dart';
import '../widgets/responsive.dart';
import 'camera_screen.dart';
import 'home_dashboard_screen.dart';
import 'pet_screen.dart';
import 'profile_screen.dart';

class TrainingScheduleScreen extends StatefulWidget {
  final String exerciseTitle;
  final String exerciseSubtitle;
  final IconData exerciseIcon;
  final DateTime? initialSelectedDate;
  final Map<String, dynamic>? newlySavedExercise;

  const TrainingScheduleScreen({
    super.key,
    required this.exerciseTitle,
    required this.exerciseSubtitle,
    required this.exerciseIcon,
    this.initialSelectedDate,
    this.newlySavedExercise,
  });

  @override
  State<TrainingScheduleScreen> createState() => _TrainingScheduleScreenState();
}

class _TrainingScheduleScreenState extends State<TrainingScheduleScreen> {
  final WorkoutScheduleService _scheduleService = WorkoutScheduleService(
    ApiClient(),
  );
  static const List<String> _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const List<String> _weekdayShort = [
    'Lun',
    'Mar',
    'Mierr',
    'Juev',
    'Vier',
    'Sab',
    'Dom',
  ];

  static const List<String> _timeSlots = [
    '06:00 AM',
    '07:00 AM',
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late DateTime _now;
  Map<String, ExercisePlan> _ejercicios =
      {}; // Mapa unificado de nombre -> plan
  bool _isLoadingSentadillas = true;
  String _selectedRoutineLabel = 'Cardio';
  String _selectedDifficultyLabel = 'Facil';
  String _selectedRepetitionsLabel = '8 - 12';
  String _selectedWeightLabel = '12 kg';
  final ScrollController _timelineController = ScrollController();
  final ScrollController _monthController = ScrollController();
  Timer? _clockTimer;
  int _selectedBottomIndex = 1;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final DateTime initialDate = widget.initialSelectedDate ?? now;
    _selectedDate = DateTime(
      initialDate.year,
      initialDate.month,
      initialDate.day,
    );
    _currentMonth = DateTime(now.year, now.month, 1);
    _now = now;

    debugPrint(
      '🔵 TrainingScheduleScreen initState - newlySavedExercise=${widget.newlySavedExercise}',
    );

    // Procesar newlySavedExercise INMEDIATAMENTE (UI optimista antes de que cargue desde BD)
    if (widget.newlySavedExercise != null) {
      _processNewlySavedExercise();
    }

    // Luego cargar desde la BD (la fuente de verdad)
    _loadExercisePlan();

    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
      _scrollToCurrentTime(animated: true);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _scrollToCurrentTime(animated: false);
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _timelineController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  void _processNewlySavedExercise() {
    if (widget.newlySavedExercise == null) return;

    try {
      final Map<String, dynamic> row = widget.newlySavedExercise!;
      final String nombre = (row['nombre'] as String?) ?? 'Ejercicio';
      final int hora = (row['hora'] is num) ? (row['hora'] as num).toInt() : 9;
      final bool completado = (row['completado'] as bool?) ?? false;

      String dificultadLabel = 'Media';
      final Object? dif = row['dificultad'];
      if (dif is num) {
        final int dv = (dif as num).toInt();
        if (dv == 1)
          dificultadLabel = 'Baja';
        else if (dv == 3)
          dificultadLabel = 'Alta';
        else
          dificultadLabel = 'Media';
      } else if (dif is String) {
        dificultadLabel = dif;
      }

      String repetitionsLabel = '';
      String weightLabel = '';

      final String tipo = (row['tipo'] as String?) ?? 'cardio';
      if (tipo == 'cardio') {
        final Object? tiempo = row['tiempo_minutos'];
        repetitionsLabel = (tiempo != null) ? '${tiempo.toString()} min' : '';
      } else {
        final Object? reps = row['repeticiones'];
        final Object? peso = row['peso'];
        repetitionsLabel = (reps != null) ? reps.toString() : '';
        weightLabel = (peso != null) ? '${peso.toString()} kg' : '';
      }

      final int hour12 = (hora % 12 == 0) ? 12 : hora % 12;
      final String period = hora >= 12 ? 'PM' : 'AM';

      final ExercisePlan newExercise = ExercisePlan(
        weekday: _selectedDate.weekday,
        hour: hour12,
        minute: 0,
        period: period,
        difficulty: dificultadLabel,
        repetitions: repetitionsLabel.isNotEmpty ? repetitionsLabel : '0',
        weight: weightLabel,
        exerciseName: nombre,
        completed: completado,
      );

      _ejercicios[nombre] = newExercise;
      debugPrint(
        '✨ INMEDIATO en initState: Ejercicio añadido al mapa: $nombre -> ${newExercise.summaryLabel}',
      );
    } catch (e) {
      debugPrint('❌ ERROR en _processNewlySavedExercise: $e');
    }
  }

  Future<void> _loadExercisePlan({DateTime? forDate}) async {
    final date = forDate ?? _selectedDate;

    debugPrint('🔄 _loadExercisePlan START - fecha=${date.toString()}');

    setState(() => _isLoadingSentadillas = true);

    try {
      // En cambios de fecha se empieza limpio para no arrastrar ejercicios de otro dia.
      Map<String, ExercisePlan> nuevosEjercicios = forDate == null
          ? Map.from(_ejercicios)
          : {};

      // ✅ ÚNICA FUENTE: Cargar ejercicios guardados por fecha (cardio + fuerza)
      try {
        final saved = await _scheduleService.loadExercisesForDate(fecha: date);
        debugPrint('📥 Cargar desde BD: ${saved.length} ejercicios');

        for (final Map<String, dynamic> row in saved) {
          try {
            final String nombre = (row['nombre'] as String?) ?? 'Ejercicio';
            final int hora = (row['hora'] is num)
                ? (row['hora'] as num).toInt()
                : 9;
            final bool completado = (row['completado'] as bool?) ?? false;

            // Dificultad: int 1-3 o string "Baja/Media/Alta"
            String dificultadLabel = 'Media';
            final Object? dif = row['dificultad'];
            if (dif is num) {
              final int dv = (dif as num).toInt();
              if (dv == 1)
                dificultadLabel = 'Baja';
              else if (dv == 3)
                dificultadLabel = 'Alta';
              else
                dificultadLabel = 'Media';
            } else if (dif is String) {
              dificultadLabel = dif;
            }

            String repetitionsLabel = '';
            String weightLabel = '';

            final String tipo = (row['tipo'] as String?) ?? 'cardio';
            if (tipo == 'cardio') {
              final Object? tiempo = row['tiempo_minutos'];
              repetitionsLabel = (tiempo != null)
                  ? '${tiempo.toString()} min'
                  : '';
            } else {
              final Object? reps = row['repeticiones'];
              final Object? peso = row['peso'];
              repetitionsLabel = (reps != null) ? reps.toString() : '';
              weightLabel = (peso != null) ? '${peso.toString()} kg' : '';
            }

            final int hour12 = (hora % 12 == 0) ? 12 : hora % 12;
            final String period = hora >= 12 ? 'PM' : 'AM';

            final ExercisePlan planFromSaved = ExercisePlan(
              weekday: date.weekday,
              hour: hour12,
              minute: 0,
              period: period,
              difficulty: dificultadLabel,
              repetitions: repetitionsLabel.isNotEmpty ? repetitionsLabel : '0',
              weight: weightLabel,
              exerciseName: nombre,
              completed: completado,
            );

            nuevosEjercicios[nombre] = planFromSaved;
            debugPrint('  ✅ $nombre (completado=$completado)');
          } catch (e) {
            debugPrint('  ⚠️ Error: $e');
          }
        }
      } catch (e) {
        debugPrint('❌ Error al cargar: $e');
      }

      if (!mounted) return;

      setState(() {
        _ejercicios = nuevosEjercicios;
        _isLoadingSentadillas = false;
      });

      debugPrint(
        '✅ Cargados ${nuevosEjercicios.length} ejercicios: ${nuevosEjercicios.keys.toList()}',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingSentadillas = false);
      debugPrint('❌ Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final List<_ScheduleItem> daySchedule = _scheduleForDate(_selectedDate);
    final double topInset = MediaQuery.of(context).padding.top;

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
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    12 * scale + topInset * 0.02,
                    20 * scale,
                    8 * scale,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12 * scale),
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const HomeDashboardScreen(),
                              ),
                              (route) => false,
                            );
                          },
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0, 0.15),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              'Programa de entrenamiento',
                              key: ValueKey<String>(
                                _monthYearTitle(_currentMonth),
                              ),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: Responsive.fs(context, 18),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 36 * scale),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _MonthArrowButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: _previousMonth,
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.12),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _monthYearTitle(_currentMonth),
                          key: ValueKey<String>(_monthYearTitle(_currentMonth)),
                          style: TextStyle(
                            color: const Color(0xFFB8B0BE),
                            fontSize: Responsive.fs(context, 15),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      _MonthArrowButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: _nextMonth,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14 * scale),
                SizedBox(height: 12 * scale),
                SizedBox(
                  height: 82 * scale,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.03, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: ListView.separated(
                      key: ValueKey<String>(_monthYearTitle(_currentMonth)),
                      controller: _monthController,
                      padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                      scrollDirection: Axis.horizontal,
                      itemCount: _buildMonthCells(_currentMonth).length,
                      separatorBuilder: (_, __) => SizedBox(width: 10 * scale),
                      itemBuilder: (context, index) {
                        final List<DateTime?> monthCells = _buildMonthCells(
                          _currentMonth,
                        );
                        final DateTime? day = monthCells[index];
                        if (day == null) {
                          return SizedBox(width: 44 * scale);
                        }

                        final bool isSelected = _isSameDay(day, _selectedDate);

                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedDate = day);
                            _loadExercisePlan(forDate: day);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            width: 56 * scale,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.primaryGradient
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(16 * scale),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.blueSecondary
                                            .withValues(alpha: 0.16),
                                        blurRadius: 12 * scale,
                                        offset: Offset(0, 5 * scale),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _weekdayShort[day.weekday - 1],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF9A96A8),
                                    fontSize: Responsive.fs(context, 10),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  '${day.day}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontSize: Responsive.fs(context, 18),
                                    fontWeight: FontWeight.w700,
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
                SizedBox(height: 12 * scale),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32 * scale),
                      ),
                    ),
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (_) => false,
                          child: ListView.builder(
                            controller: _timelineController,
                            padding: EdgeInsets.fromLTRB(
                              16 * scale,
                              18 * scale,
                              16 * scale,
                              92 * scale,
                            ),
                            itemCount: _timeSlots.length,
                            itemBuilder: (context, index) {
                              final String time = _timeSlots[index];
                              final _ScheduleItem? item = daySchedule
                                  .cast<_ScheduleItem?>()
                                  .firstWhere(
                                    (entry) =>
                                        entry != null && entry.time == time,
                                    orElse: () => null,
                                  );
                              final bool isCurrentSlot =
                                  _isTodaySelected() && _isCurrentSlot(index);

                              return Padding(
                                padding: EdgeInsets.only(bottom: 10 * scale),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 68 * scale,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 8 * scale,
                                        ),
                                        child: Text(
                                          time,
                                          style: TextStyle(
                                            color: const Color(0xFFB8B0BE),
                                            fontSize: Responsive.fs(
                                              context,
                                              11,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 240,
                                            ),
                                            transitionBuilder:
                                                (child, animation) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: ScaleTransition(
                                                      scale: Tween<double>(
                                                        begin: 0.96,
                                                        end: 1,
                                                      ).animate(animation),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                            child: item == null
                                                ? SizedBox(height: 44 * scale)
                                                : GestureDetector(
                                                    onTap:
                                                        item.exerciseName !=
                                                                null &&
                                                            !item.isCompleted
                                                        ? () => _showMarkCompleteDialog(
                                                            item.exerciseName!,
                                                          )
                                                        : null,
                                                    child: Container(
                                                      key: ValueKey<String>(
                                                        '${item.exercise}-${item.time}-${_selectedDate.toIso8601String()}',
                                                      ),
                                                      width: double.infinity,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal:
                                                                16 * scale,
                                                            vertical:
                                                                12 * scale,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: item.isCompleted
                                                            ? const Color(
                                                                0xFF4CAF50,
                                                              ).withValues(
                                                                alpha: 0.6,
                                                              )
                                                            : item.color
                                                                  .withValues(
                                                                    alpha: 1.0,
                                                                  ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24 * scale,
                                                            ),
                                                      ),
                                                      child: Opacity(
                                                        opacity:
                                                            item.isCompleted
                                                            ? 0.65
                                                            : 1.0,
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              width: 10 * scale,
                                                              height:
                                                                  10 * scale,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color:
                                                                    item.isCompleted
                                                                    ? const Color(
                                                                        0xFFFFFFFF,
                                                                      )
                                                                    : Colors
                                                                          .white,
                                                              ),
                                                              child:
                                                                  item.isCompleted
                                                                  ? Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: const Color(
                                                                        0xFF4CAF50,
                                                                      ),
                                                                      size:
                                                                          6 *
                                                                          scale,
                                                                    )
                                                                  : null,
                                                            ),
                                                            SizedBox(
                                                              width: 10 * scale,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                item.exercise,
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      Responsive.fs(
                                                                        context,
                                                                        13,
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  decoration:
                                                                      item.isCompleted
                                                                      ? TextDecoration
                                                                            .lineThrough
                                                                      : TextDecoration
                                                                            .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          if (isCurrentSlot)
                                            Positioned(
                                              left: 0,
                                              right: 0,
                                              top: 18 * scale,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 11 * scale,
                                                    height: 11 * scale,
                                                    decoration:
                                                        const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                            0xFFE64949,
                                                          ),
                                                        ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 3,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFFE64949,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              99,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8 * scale),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8 * scale,
                                                          vertical: 4 * scale,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFE64949,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            999,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFE64949,
                                                              ).withValues(
                                                                alpha: 0.26,
                                                              ),
                                                          blurRadius: 8 * scale,
                                                          offset: Offset(
                                                            0,
                                                            3 * scale,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      'Ahora',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: Responsive.fs(
                                                          context,
                                                          10,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 88 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EEEF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24 * scale),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TrainingBottomBarIcon(
                        icon: Icons.home_rounded,
                        isActive: _selectedBottomIndex == 0,
                        scale: scale,
                        onTap: () => _handleBottomTap(0),
                      ),
                      _TrainingBottomBarIcon(
                        icon: Icons.query_stats_rounded,
                        isActive: _selectedBottomIndex == 1,
                        scale: scale,
                        onTap: () => _handleBottomTap(1),
                      ),
                      _TrainingBottomBarIcon(
                        icon: Icons.pets_rounded,
                        isActive: _selectedBottomIndex == 2,
                        scale: scale,
                        isPrimary: true,
                        onTap: () => _handleBottomTap(2),
                      ),
                      _TrainingBottomBarIcon(
                        icon: Icons.camera_alt_outlined,
                        isActive: _selectedBottomIndex == 3,
                        scale: scale,
                        onTap: () => _handleBottomTap(3),
                      ),
                      _TrainingBottomBarIcon(
                        icon: Icons.person_outline_rounded,
                        isActive: _selectedBottomIndex == 4,
                        scale: scale,
                        onTap: () => _handleBottomTap(4),
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

  bool _isTodaySelected() {
    final DateTime today = DateTime.now();
    return _isSameDay(
      _selectedDate,
      DateTime(today.year, today.month, today.day),
    );
  }

  bool _isCurrentSlot(int index) {
    final double currentHour = _now.hour + (_now.minute / 60.0);
    final double slotHour = 6 + index.toDouble();
    return currentHour >= slotHour && currentHour < slotHour + 1;
  }

  void _scrollToCurrentTime({required bool animated}) {
    if (!_isTodaySelected() || !_timelineController.hasClients) {
      return;
    }

    const double startHour = 6;
    const double rowHeight = 54;
    final double currentHour = _now.hour + (_now.minute / 60.0);
    final double target = ((currentHour - startHour) * rowHeight).clamp(
      0.0,
      (_timeSlots.length - 1) * rowHeight,
    );

    if (animated) {
      _timelineController.animateTo(
        target,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    } else {
      _timelineController.jumpTo(target);
    }
  }

  String _formatCurrentTimeLabel() {
    final int hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final String minute = _now.minute.toString().padLeft(2, '0');
    final String period = _now.hour >= 12 ? 'PM' : 'AM';
    return '$hour12:$minute $period';
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDate = _clampSelectedDateToMonth(_selectedDate, _currentMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDate = _clampSelectedDateToMonth(_selectedDate, _currentMonth);
    });
  }

  void _showMarkCompleteDialog(String exerciseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marcar como completado'),
          content: Text('¿Deseas marcar "$exerciseName" como completado?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _removeExercise(exerciseName);
              },
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _markExerciseComplete(exerciseName);
              },
              child: const Text('Sí, completado'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markExerciseComplete(String exerciseName) async {
    try {
      debugPrint(
        '📝 Marcando $exerciseName como completado para fecha ${_selectedDate}',
      );

      final rachaService = RachaService();
      final fechaFormato = _selectedDate.toIso8601String().split('T')[0];
      final response = await rachaService.marcarEjercicioCompletado(
        nombre: exerciseName,
        fecha: fechaFormato,
      );

      if (!mounted) return;

      debugPrint('✅ $exerciseName marcado como completado');
      debugPrint(
        '🔥 Racha actualizada: ${response['dias_racha']} días (Activa: ${response['racha_activa']})',
      );

      // Mostrar recompensas si existen en la respuesta
      final recompensas = response['recompensas'] as List?;
      if (recompensas != null && recompensas.isNotEmpty) {
        String rewardMsg = '🎁 ¡Recompensas recibidas!\n';
        for (var reward in recompensas) {
          if (reward is Map) {
            rewardMsg +=
                '${reward['nombre'] ?? 'Recompensa'}: +${reward['cantidad'] ?? 0}\n';
          }
        }
        debugPrint(rewardMsg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(rewardMsg.trim()),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Mostrar desbloqueo de ropa si aplica
      final atuendosNuevos =
          (response['atuendos_nuevos'] ?? response['atuendosNuevos']) as List?;
      final bool atuendosDesbloqueados =
          (response['atuendos_desbloqueados'] ??
              response['atuendosDesbloqueados']) ==
          true;
      if (atuendosDesbloqueados &&
          atuendosNuevos != null &&
          atuendosNuevos.isNotEmpty) {
        final String clothMsg =
            '¡Atuendos desbloqueados!\n${atuendosNuevos.join('\n')}';
        debugPrint(clothMsg);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clothMsg),
            backgroundColor: Colors.purple,
            duration: const Duration(seconds: 4),
          ),
        );
      }

      // Recargar los ejercicios para actualizar la UI inmediatamente
      await _loadExercisePlan(forDate: _selectedDate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $exerciseName marcado como completado'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error al marcar $exerciseName como completado: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _removeExercise(String exerciseName) async {
    try {
      debugPrint('🗑️ Eliminando $exerciseName de la fecha ${_selectedDate}');

      await _scheduleService.deleteExercise(
        nombre: exerciseName,
        fecha: _selectedDate,
      );

      debugPrint('✅ $exerciseName eliminado');

      // Remover inmediatamente del mapa local para actualizar la UI
      setState(() {
        _ejercicios.remove(exerciseName);
      });

      // Luego recargar desde la BD por si acaso
      if (!mounted) return;
      await _loadExercisePlan(forDate: _selectedDate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ $exerciseName eliminado'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error al eliminar $exerciseName: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddExerciseSheet() {
    // Only allow the full 'Horario por dia' sheet for Sentadillas.
    if (!widget.exerciseTitle.toLowerCase().contains('sentad')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponible sólo para Sentadillas')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final double scale = Responsive.scale(context);
        // Rango permitido: 6 AM a 8 PM (6 a 20 en formato 24h)
        // Generar lista de horas de 6 AM a 8 PM con formato correcto
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

        // Hora actual
        int now24Hour = _now.hour;
        int nowMinute = _now.minute;

        // Validar que la hora actual esté dentro del rango permitido (6 AM - 8 PM)
        if (now24Hour < 6) now24Hour = 6; // Si es antes de 6 AM, poner 6 AM
        if (now24Hour >= 20) now24Hour = 20; // Si es 8 PM o después, poner 8 PM

        int initialMinute = nowMinute;
        // Índice inicial de la hora en el picker (0-14 para 6-20)
        int initialHourIndex = now24Hour - 6;

        return StatefulBuilder(
          builder: (context, setState) {
            final bool isMobile = MediaQuery.of(context).size.width < 600;

            int selectedHourIndex =
                initialHourIndex; // Índice 0-14 que corresponde a horas 6-20
            int selectedMinute = initialMinute;

            Widget detailItem({
              required String title,
              required String subtitle,
              required IconData icon,
              required VoidCallback onTap,
            }) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18 * scale),
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 10 * scale),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * scale,
                      vertical: 12 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F8),
                      borderRadius: BorderRadius.circular(18 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          color: const Color(0xFFB9B7C8),
                          size: 18 * scale,
                        ),
                        SizedBox(width: 10 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: Responsive.fs(context, 13),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  color: const Color(0xFFB4B1C1),
                                  fontSize: Responsive.fs(context, 11),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: const Color(0xFF9B97AA),
                            fontSize: Responsive.fs(context, 12),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 6 * scale),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: const Color(0xFF9B97AA),
                          size: 22 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final Widget sheet = SafeArea(
              top: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: isMobile
                        ? const BorderRadius.vertical(top: Radius.circular(30))
                        : BorderRadius.circular(30),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 520,
                      maxHeight: MediaQuery.of(context).size.height * 0.95,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          18 * scale,
                          20 * scale,
                          18 * scale,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Material(
                                  color: const Color(0xFFF6F6F6),
                                  borderRadius: BorderRadius.circular(
                                    12 * scale,
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      12 * scale,
                                    ),
                                    onTap: () => Navigator.pop(context),
                                    child: SizedBox(
                                      width: 34 * scale,
                                      height: 34 * scale,
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 18 * scale,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Horario por dia',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: Responsive.fs(context, 18),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 34 * scale),
                              ],
                            ),
                            SizedBox(height: 16 * scale),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  color: const Color(0xFFBFC3D7),
                                  size: 18 * scale,
                                ),
                                SizedBox(width: 8 * scale),
                                Text(
                                  _weekdayShort[_selectedDate.weekday - 1],
                                  style: TextStyle(
                                    color: const Color(0xFFBFC3D7),
                                    fontSize: Responsive.fs(context, 13),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 18 * scale),
                            Text(
                              'Hora',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: Responsive.fs(context, 15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10 * scale),
                            SizedBox(
                              height: isMobile ? 148 * scale : 140 * scale,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CupertinoPicker(
                                      backgroundColor: Colors.white,
                                      itemExtent: 32 * scale,
                                      scrollController:
                                          FixedExtentScrollController(
                                            initialItem: selectedHourIndex,
                                          ),
                                      onSelectedItemChanged: (index) =>
                                          setState(
                                            () => selectedHourIndex = index,
                                          ),
                                      children: hours
                                          .map(
                                            (value) => Center(
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: Responsive.fs(
                                                    context,
                                                    18,
                                                  ),
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                  Expanded(
                                    child: CupertinoPicker(
                                      backgroundColor: Colors.white,
                                      itemExtent: 32 * scale,
                                      scrollController:
                                          FixedExtentScrollController(
                                            initialItem: selectedMinute,
                                          ),
                                      onSelectedItemChanged: (index) =>
                                          setState(
                                            () => selectedMinute = index,
                                          ),
                                      children: minutes
                                          .map(
                                            (value) => Center(
                                              child: Text(
                                                value,
                                                style: TextStyle(
                                                  fontSize: Responsive.fs(
                                                    context,
                                                    18,
                                                  ),
                                                  color: AppColors.textPrimary,
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
                            SizedBox(height: 18 * scale),
                            Text(
                              'Detalles de rutina',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: Responsive.fs(context, 15),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            detailItem(
                              title: 'Elegir rutina',
                              subtitle: _selectedRoutineLabel,
                              icon: Icons.fitness_center_outlined,
                              onTap: () async {
                                final String? selected =
                                    await Navigator.of(context).push<String>(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const RoutineSelectionScreen(),
                                      ),
                                    );

                                if (selected != null && selected.isNotEmpty) {
                                  this.setState(() {
                                    _selectedRoutineLabel = selected;
                                  });
                                }
                              },
                            ),
                            detailItem(
                              title: 'Dificultad',
                              subtitle: _selectedDifficultyLabel,
                              icon: Icons.swap_vert_rounded,
                              onTap: () {},
                            ),
                            detailItem(
                              title: 'Ajustar repeticiones',
                              subtitle: _selectedRepetitionsLabel,
                              icon: Icons.bar_chart_outlined,
                              onTap: () {},
                            ),
                            detailItem(
                              title: 'Ajustar pesos',
                              subtitle: _selectedWeightLabel,
                              icon: Icons.monitor_weight_outlined,
                              onTap: () {},
                            ),
                            SizedBox(height: 18 * scale),
                            SizedBox(
                              width: double.infinity,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  height: 58 * scale,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      28 * scale,
                                    ),
                                    gradient: AppColors.primaryGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.blueSecondary
                                            .withValues(alpha: 0.18),
                                        blurRadius: 18 * scale,
                                        offset: Offset(0, 8 * scale),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Guardar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: Responsive.fs(context, 15),
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
                ),
              ),
            );

            if (isMobile) {
              return FractionallySizedBox(heightFactor: 0.96, child: sheet);
            }

            return Center(child: sheet);
          },
        );
      },
    );
  }

  List<DateTime?> _buildMonthCells(DateTime month) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final int leadingEmptyCells = (month.weekday + 6) % 7;

    final List<DateTime?> cells = List<DateTime?>.filled(
      leadingEmptyCells,
      null,
      growable: true,
    );
    for (int day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(month.year, month.month, day));
    }
    return cells;
  }

  int _monthRowCount(DateTime month) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final int leadingEmptyCells = (month.weekday + 6) % 7;
    return ((leadingEmptyCells + daysInMonth) / 7).ceil();
  }

  double _monthGridHeight(double scale, int rows) {
    return (rows * (54 * scale)) + ((rows - 1) * (10 * scale)) + (8 * scale);
  }

  DateTime _clampSelectedDateToMonth(DateTime selected, DateTime month) {
    final int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final int day = selected.day.clamp(1, daysInMonth);
    return DateTime(month.year, month.month, day);
  }

  List<_ScheduleItem> _scheduleForDate(DateTime date) {
    final int weekday = date.weekday;
    List<_ScheduleItem> items = [];

    debugPrint(
      '📋 _scheduleForDate LLAMADO - fecha=$date, weekday=$weekday, _ejercicios.keys=${_ejercicios.keys.toList()}',
    );

    // Agregar todos los ejercicios cargados del mapa unificado
    for (var entry in _ejercicios.entries) {
      final String nombre = entry.key;
      final ExercisePlan ejercicio = entry.value;
      // Usar el estado completado del objeto ExercisePlan, no del Set
      items.add(
        _ScheduleItem(
          time: ejercicio.timeLabel,
          exercise: ejercicio.summaryLabel,
          color: const Color(0xFF70E0F0),
          exerciseName: nombre,
          isCompleted: ejercicio.completed,
        ),
      );
      debugPrint(
        '📋 Agregado item: $nombre -> ${ejercicio.summaryLabel} (completado=${ejercicio.completed})',
      );
    }

    // Si hay ejercicios cargados, retornarlos
    if (items.isNotEmpty) {
      debugPrint('📋 Retornando ${items.length} items del mapa');
      return items;
    }

    return [];
  }

  String _monthYearTitle(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  void _handleBottomTap(int index) {
    setState(() => _selectedBottomIndex = index);

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PetScreen()));
    } else if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CameraScreen()));
    } else if (index == 4) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }
}

class _TrainingBottomBarIcon extends StatelessWidget {
  const _TrainingBottomBarIcon({
    required this.icon,
    required this.scale,
    required this.onTap,
    this.isActive = false,
    this.isPrimary = false,
  });

  final IconData icon;
  final double scale;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          scale: isActive ? 1.08 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isActive ? 62 * scale : 58 * scale,
            height: isActive ? 62 * scale : 58 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueSecondary.withValues(
                    alpha: isActive ? 0.35 : 0.20,
                  ),
                  blurRadius: (isActive ? 18 : 12) * scale,
                  offset: Offset(0, 8 * scale),
                ),
              ],
            ),
            child: Icon(
              Icons.pets_rounded,
              color: Colors.white,
              size: 30 * scale,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: 8 * scale,
          vertical: 6 * scale,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.mintPrimary.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Icon(
          icon,
          size: 27 * scale,
          color: isActive ? AppColors.mintPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _MonthArrowButton extends StatelessWidget {
  const _MonthArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: const Color(0xFF9C96A8), size: 24),
        ),
      ),
    );
  }
}

class _ScheduleItem {
  final String time;
  final String exercise;
  final Color color;
  final String?
  exerciseName; // Nombre del ejercicio para marcar como completado
  final bool isCompleted; // Si está marcado como completado

  _ScheduleItem({
    required this.time,
    required this.exercise,
    required this.color,
    this.exerciseName,
    this.isCompleted = false,
  });
}

class _TimelineGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const double topOffset = 20;
    const double step = 56;

    for (double y = topOffset; y < size.height; y += step) {
      canvas.drawLine(Offset(88, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.title,
    this.subtitle = '',
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 14 * scale,
            vertical: 12 * scale,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(14 * scale),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      SizedBox(height: 6 * scale),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: const Color(0xFF9A96A8),
                          fontSize: Responsive.fs(context, 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: const Color(0xFF9A96A8)),
            ],
          ),
        ),
      ),
    );
  }
}
