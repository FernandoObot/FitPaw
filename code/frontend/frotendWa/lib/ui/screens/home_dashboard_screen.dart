import 'package:flutter/material.dart';
import 'dart:convert';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import 'activity_history_screen.dart';
import 'camera_screen.dart';
import 'pet_screen.dart';
import 'profile_screen.dart';
import 'training_schedule_screen.dart';
import 'exercise_detail_screen.dart';
import 'running_screen.dart';
import 'press_hombros_screen.dart';
import 'flexion_una_pierna_screen.dart';
import 'sentadillas_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _streakController;
  late final AuthService _authService;
  String _profileName = 'Usuario';
  bool _loadingProfileName = true;
  int _selectedBottomIndex = 0;
  int _selectedTaskIndex = 0;
  int _pressedTaskIndex = -1;
  bool _isReviewPressed = false;
  int _diasRacha = 0;
  bool _loadingRacha = true;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiClient());
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat(reverse: true);
    _loadProfileName();
    _loadRachaData();
  }

  @override
  void dispose() {
    _streakController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileName() async {
    debugPrint('📱 Iniciando _loadProfileName()');
    try {
      final result = await _authService.getProfile();
      debugPrint('📱 Resultado getProfile: $result');
      
      if (!mounted) {
        debugPrint('📱 Widget no está mounted, cancelando actualización');
        return;
      }

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        debugPrint('📱 Datos del perfil obtenidos: $data');
        final nickname = data['nickname'] as String?;
        
        setState(() {
          if (nickname != null && nickname.trim().isNotEmpty) {
            _profileName = nickname;
            debugPrint('✅ Nombre cargado desde API: $_profileName');
          } else {
            debugPrint('⚠️ Nickname vacío o null, usando: $_profileName');
          }
          _loadingProfileName = false;
        });
      } else {
        final error = result['error'];
        debugPrint('❌ Error al cargar perfil: $error');
        setState(() {
          _loadingProfileName = false;
          // Mantener el nombre por defecto si hay error
          debugPrint('⚠️ Usando nombre por defecto: $_profileName');
        });
      }
    } catch (e) {
      debugPrint('❌ Excepción en _loadProfileName: $e');
      if (mounted) {
        setState(() => _loadingProfileName = false);
      }
    }
  }

  Future<void> _loadRachaData() async {
    debugPrint('🔥 Cargando datos de racha...');
    try {
      final response = await ApiClient().get('/streak/info', needsAuth: true);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _diasRacha = data['conteoDias'] ?? 0;
          _loadingRacha = false;
          debugPrint('✅ Racha cargada: $_diasRacha días');
        });
      } else {
        setState(() {
          _diasRacha = 0;
          _loadingRacha = false;
          debugPrint('⚠️ Error al cargar racha: ${response.statusCode}');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _diasRacha = 0;
          _loadingRacha = false;
          debugPrint('❌ Error cargando racha: $e');
        });
      }
    }
  }

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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(28 * scale, 18 * scale, 28 * scale, 18 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenida de vuelta,',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: Responsive.fs(context, 16),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child: Text(
                                      _loadingProfileName ? '...' : _profileName,
                                      key: ValueKey<String>(_profileName),
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: Responsive.fs(context, 42),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18 * scale),
                        Container(
                          height: 160 * scale,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24 * scale),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/Banner-Dots.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 16 * scale),
                          child: Row(
                            children: [
                              AnimatedBuilder(
                                animation: _streakController,
                                builder: (context, child) {
                                  final double pulse = 1 + (_streakController.value * 0.12);
                                  return Transform.scale(
                                    scale: pulse,
                                    child: Container(
                                      width: 58 * scale,
                                      height: 58 * scale,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withValues(alpha: 0.30 * _streakController.value),
                                            blurRadius: 22 * scale,
                                            spreadRadius: 2 * scale,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.local_fire_department_outlined,
                                        color: Colors.white,
                                        size: 40 * scale,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 14 * scale),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _loadingRacha ? '-' : '$_diasRacha',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: Responsive.fs(context, 56),
                                        fontWeight: FontWeight.w700,
                                        height: 0.95,
                                      ),
                                    ),
                                    SizedBox(height: 2 * scale),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Dias de racha',
                                        maxLines: 1,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.fs(context, 20),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 140),
                          scale: _isReviewPressed ? 0.98 : 1,
                          child: Material(
                            color: const Color(0xFFD8ECE4),
                            borderRadius: BorderRadius.circular(18 * scale),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18 * scale),
                              onTapDown: (_) => setState(() => _isReviewPressed = true),
                              onTapCancel: () => setState(() => _isReviewPressed = false),
                              onTap: () {
                                setState(() => _isReviewPressed = false);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ActivityHistoryScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 13 * scale),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Objetivo del dia - Lunes',
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: Responsive.fs(context, 16),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 8 * scale),
                                      decoration: BoxDecoration(
                                        color: _isReviewPressed
                                            ? AppColors.mintPrimary.withValues(alpha: 0.85)
                                            : AppColors.mintPrimary,
                                        borderRadius: BorderRadius.circular(26 * scale),
                                      ),
                                      child: Text(
                                        'Revisar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: Responsive.fs(context, 13),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        _GoalTaskTile(
                          index: 0,
                          selectedTaskIndex: _selectedTaskIndex,
                          pressedTaskIndex: _pressedTaskIndex,
                          onPressedStateChanged: (pressed) => _setTaskPressedState(0, pressed),
                          onTap: () => _selectTask(0),
                          icon: Icons.directions_run_rounded,
                          title: 'Sentadillas',
                          subtitle: '3 series de 15 reps',
                        ),
                        SizedBox(height: 10 * scale),
                        _GoalTaskTile(
                          index: 1,
                          selectedTaskIndex: _selectedTaskIndex,
                          pressedTaskIndex: _pressedTaskIndex,
                          onPressedStateChanged: (pressed) => _setTaskPressedState(1, pressed),
                          onTap: () => _selectTask(1),
                          icon: Icons.fitness_center_rounded,
                          title: 'Press de hombros',
                          subtitle: '3 series de 12 reps',
                        ),
                        SizedBox(height: 10 * scale),
                        _GoalTaskTile(
                          index: 2,
                          selectedTaskIndex: _selectedTaskIndex,
                          pressedTaskIndex: _pressedTaskIndex,
                          onPressedStateChanged: (pressed) => _setTaskPressedState(2, pressed),
                          onTap: () => _selectTask(2),
                          icon: Icons.accessibility_new_rounded,
                          title: 'Flexion de una pierna (con pesas)',
                          subtitle: '12 reps por pierna',
                        ),
                        SizedBox(height: 10 * scale),
                        _GoalTaskTile(
                          index: 3,
                          selectedTaskIndex: _selectedTaskIndex,
                          pressedTaskIndex: _pressedTaskIndex,
                          onPressedStateChanged: (pressed) => _setTaskPressedState(3, pressed),
                          onTap: () => _selectTask(3),
                          icon: Icons.directions_walk_rounded,
                          title: 'Correr',
                          subtitle: '20 minutos (ritmo suave)',
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 88 * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4EEEF),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double segmentWidth = constraints.maxWidth / 5;

                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final int nextIndex =
                              (details.localPosition.dx / segmentWidth).clamp(0, 4).floor();
                          if (nextIndex != _selectedBottomIndex) {
                            _handleBottomTap(nextIndex);
                          } else if (nextIndex == 4 || nextIndex == 2) {
                            _handleBottomTap(nextIndex);
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          final int nextIndex =
                              (details.localPosition.dx / segmentWidth).clamp(0, 4).floor();
                          if (nextIndex != _selectedBottomIndex) {
                            setState(() => _selectedBottomIndex = nextIndex);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _BottomBarIcon(
                              icon: Icons.home_rounded,
                              isActive: _selectedBottomIndex == 0,
                              scale: scale,
                              onTap: () => _selectBottom(0),
                            ),
                            _BottomBarIcon(
                              icon: Icons.query_stats_rounded,
                              isActive: _selectedBottomIndex == 1,
                              scale: scale,
                              onTap: () => _selectBottom(1),
                            ),
                            _BottomBarIcon(
                              icon: Icons.pets_rounded,
                              isActive: _selectedBottomIndex == 2,
                              scale: scale,
                              isPrimary: true,
                              onTap: () => _handleBottomTap(2),
                            ),
                            _BottomBarIcon(
                              icon: Icons.camera_alt_outlined,
                              isActive: _selectedBottomIndex == 3,
                              scale: scale,
                              onTap: () => _selectBottom(3),
                            ),
                            _BottomBarIcon(
                              icon: Icons.person_outline_rounded,
                              isActive: _selectedBottomIndex == 4,
                              scale: scale,
                              onTap: () => _handleBottomTap(4),
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
      ),
    );
  }

  void _selectBottom(int index) {
    setState(() => _selectedBottomIndex = index);
  }

  void _handleBottomTap(int index) {
    _selectBottom(index);

    if (index == 1) {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (_) => TrainingScheduleScreen(
                  exerciseTitle: 'Sentadillas',
                  exerciseSubtitle: '3 series de 15 reps',
                  exerciseIcon: Icons.directions_run_rounded,
                ),
              ),
            )
            .then((_) => _selectBottom(0));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PetScreen()))
          .then((_) => _selectBottom(0));
    } else if (index == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CameraScreen()))
          .then((_) => _selectBottom(0));
    } else if (index == 4) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const ProfileScreen()))
          .then((_) => _selectBottom(0));
    }
  }

  void _selectTask(int index) {
    setState(() => _selectedTaskIndex = index);

    final List<Map<String, dynamic>> tasks = [
      {
        'title': 'Sentadillas',
        'subtitle': '3 series de 15 reps',
        'icon': Icons.directions_run_rounded,
      },
      {
        'title': 'Press de hombros',
        'subtitle': '3 series de 12 reps',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'title': 'Flexion de una pierna (con pesas)',
        'subtitle': '12 reps por pierna',
        'icon': Icons.accessibility_new_rounded,
      },
      {
        'title': 'Correr',
        'subtitle': '20 minutos (ritmo suave)',
        'icon': Icons.directions_run_rounded,
      },
    ];

    final task = tasks[index];
    if (index == 0) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              builder: (_) => SentadillasScreen(selectedDate: DateTime.now()),
            ),
          )
          .then((_) => setState(() => _selectedTaskIndex = 0));
    } else if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => PressHombrosScreen(selectedDate: DateTime.now())))
          .then((_) => setState(() => _selectedTaskIndex = 0));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => FlexionUnaPiernaScreen(selectedDate: DateTime.now())))
          .then((_) => setState(() => _selectedTaskIndex = 0));
    } else if (index == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => RunningScreen(selectedDate: DateTime.now())))
          .then((_) => setState(() => _selectedTaskIndex = 0));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(
            title: task['title'] as String,
            subtitle: task['subtitle'] as String,
            icon: task['icon'] as IconData,
          ),
        ),
      );
    }
  }

  void _setTaskPressedState(int index, bool pressed) {
    setState(() => _pressedTaskIndex = pressed ? index : -1);
  }
}

class _GoalTaskTile extends StatelessWidget {
  const _GoalTaskTile({
    required this.index,
    required this.selectedTaskIndex,
    required this.pressedTaskIndex,
    required this.onPressedStateChanged,
    required this.onTap,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final int index;
  final int selectedTaskIndex;
  final int pressedTaskIndex;
  final ValueChanged<bool> onPressedStateChanged;
  final VoidCallback onTap;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final bool isSelected = selectedTaskIndex == index;
    final bool isPressed = pressedTaskIndex == index;

    return AnimatedScale(
      scale: isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16 * scale),
          onTap: onTap,
          onHighlightChanged: onPressedStateChanged,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: isSelected ? AppColors.mintPrimary.withValues(alpha: 0.80) : const Color(0xFFECECEC),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.mintPrimary.withValues(alpha: 0.18),
                        blurRadius: 16 * scale,
                        offset: Offset(0, 6 * scale),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 58 * scale,
                  height: 58 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFFCFEFE7) : const Color(0xFFD9EEE9),
                  ),
                  child: Icon(icon, color: AppColors.deepNavy, size: 28 * scale),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: Responsive.fs(context, 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 3 * scale),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fs(context, 12),
                          fontWeight: FontWeight.w400,
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

class _BottomBarIcon extends StatelessWidget {
  const _BottomBarIcon({
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
                  color: AppColors.blueSecondary.withValues(alpha: isActive ? 0.35 : 0.20),
                  blurRadius: (isActive ? 18 : 12) * scale,
                  offset: Offset(0, 8 * scale),
                ),
              ],
            ),
            child: Icon(Icons.pets_rounded, color: Colors.white, size: 30 * scale),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: isActive ? AppColors.mintPrimary.withValues(alpha: 0.16) : Colors.transparent,
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
