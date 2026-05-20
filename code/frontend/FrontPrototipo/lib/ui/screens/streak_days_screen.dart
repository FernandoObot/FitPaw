import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';

class StreakDaysScreen extends StatefulWidget {
  const StreakDaysScreen({super.key});

  @override
  State<StreakDaysScreen> createState() => _StreakDaysScreenState();
}

class _StreakDaysScreenState extends State<StreakDaysScreen> with TickerProviderStateMixin {
  late final AnimationController _streakController;
  late final AnimationController _claimFlashController;
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  int _selectedRewardIndex = 0;
  final Set<int> _claimedRewards = <int>{};
  int? _flashRewardIndex;

  @override
  void initState() {
    super.initState();
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat(reverse: true);
    _claimFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _streakController.dispose();
    _claimFlashController.dispose();
    super.dispose();
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
                            'Dias de racha',
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 20 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StreakHeader(controller: _streakController),
                        SizedBox(height: 18 * scale),
                        _CalendarCard(
                          focusedMonth: _focusedMonth,
                          onPrevious: _goToPreviousMonth,
                          onNext: _goToNextMonth,
                        ),
                        SizedBox(height: 18 * scale),
                        _GoalCard(),
                        SizedBox(height: 18 * scale),
                        Text(
                          'Logros de racha',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: Responsive.fs(context, 15),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10 * scale),
                        _RewardTile(
                          index: 0,
                          selectedIndex: _selectedRewardIndex,
                          isClaimed: _claimedRewards.contains(0),
                          isFlashing: _flashRewardIndex == 0,
                          flashController: _claimFlashController,
                          title: 'Recompensa por 15 dias de racha',
                          onTap: () => _claimReward(0),
                          accentColor: AppColors.mintPrimary,
                          icon: Icons.sports_football_rounded,
                        ),
                        SizedBox(height: 10 * scale),
                        _RewardTile(
                          index: 1,
                          selectedIndex: _selectedRewardIndex,
                          isClaimed: _claimedRewards.contains(1),
                          isFlashing: _flashRewardIndex == 1,
                          flashController: _claimFlashController,
                          title: 'Recompensa por 20 dias de racha',
                          onTap: () => _claimReward(1),
                          accentColor: AppColors.textSecondary,
                          icon: Icons.checkroom_rounded,
                        ),
                      ],
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

  void _goToPreviousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _claimReward(int index) {
    setState(() {
      _selectedRewardIndex = index;
      _claimedRewards.add(index);
      _flashRewardIndex = index;
    });

    _claimFlashController.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) {
        return;
      }
      setState(() => _flashRewardIndex = null);
    });
  }
}

class _StreakHeader extends StatelessWidget {
  const _StreakHeader({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Row(
      children: [
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final double pulse = 1 + (controller.value * 0.12);
            return Transform.scale(
              scale: pulse,
              child: Container(
                width: 70 * scale,
                height: 70 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blueSecondary.withValues(alpha: 0.20 * controller.value),
                      blurRadius: 20 * scale,
                      spreadRadius: 2 * scale,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.blueSecondary,
                  size: 40 * scale,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 16 * scale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '15',
              style: TextStyle(
                color: AppColors.blueSecondary,
                fontSize: Responsive.fs(context, 36),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Dias de racha',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.fs(context, 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.focusedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime focusedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  static const List<String> _weekdays = ['LUN', 'MAR', 'MIER', 'JUE', 'VIER', 'SAB', 'DOM'];
  static const List<String> _months = [
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

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final List<DateTime?> days = _buildDays(focusedMonth);
    final Set<int> streakDays = {1, 2, 3, 6, 7, 8, 9, 10, 12, 13, 15, 20, 22};

    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFEAFBF8),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calendario de racha',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: Responsive.fs(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppColors.textPrimary,
                onPressed: onPrevious,
              ),
              Text(
                '${_months[focusedMonth.month - 1]} - ${focusedMonth.year}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: Responsive.fs(context, 12),
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppColors.textPrimary,
                onPressed: onNext,
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekdays
                .map(
                  (day) => Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: Responsive.fs(context, 10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8 * scale),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final DateTime? date = days[index];
              final bool isCurrentMonth = date != null;
              final bool isStreakDay = isCurrentMonth && streakDays.contains(date!.day);

              return _CalendarCell(
                dayNumber: isCurrentMonth ? date!.day.toString() : '',
                isStreak: isStreakDay,
                scale: scale,
              );
            },
          ),
        ],
      ),
    );
  }

  List<DateTime?> _buildDays(DateTime month) {
    final DateTime first = DateTime(month.year, month.month, 1);
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int leadingEmpty = (first.weekday + 6) % 7;
    final List<DateTime?> result = <DateTime?>[];

    for (int i = 0; i < leadingEmpty; i++) {
      result.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      result.add(DateTime(month.year, month.month, day));
    }

    while (result.length % 7 != 0) {
      result.add(null);
    }

    while (result.length < 35) {
      result.add(null);
    }

    return result;
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.dayNumber,
    required this.isStreak,
    required this.scale,
  });

  final String dayNumber;
  final bool isStreak;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final Color baseColor = isStreak ? const Color(0xFFD7F3EE) : const Color(0xFFF2F2F2);

    return Container(
      decoration: BoxDecoration(
        color: dayNumber.isEmpty ? Colors.transparent : baseColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isStreak
            ? Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.mintPrimary,
                size: 14 * scale,
              )
            : Text(
                dayNumber,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: Responsive.fs(context, 10),
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 14 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFAF7),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Meta de racha',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: Responsive.fs(context, 14),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              _GoalIcon(value: '10'),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Container(
                  height: 16 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20 * scale),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 120 * scale,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12 * scale),
              _GoalIcon(value: '15'),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            '10/20 dias',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: Responsive.fs(context, 11),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalIcon extends StatelessWidget {
  const _GoalIcon({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      width: 30 * scale,
      height: 30 * scale,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: Responsive.fs(context, 11),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.index,
    required this.selectedIndex,
    required this.isClaimed,
    required this.isFlashing,
    required this.flashController,
    required this.title,
    required this.onTap,
    required this.accentColor,
    required this.icon,
  });

  final int index;
  final int selectedIndex;
  final bool isClaimed;
  final bool isFlashing;
  final AnimationController flashController;
  final String title;
  final VoidCallback onTap;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);
    final bool isSelected = index == selectedIndex;
    final String buttonText = isClaimed ? 'RECLAMADO' : 'RECLAMAR';
    final Color buttonColor = isClaimed ? const Color(0xFFBFC5C8) : AppColors.mintPrimary;
    final Color buttonTextColor = isClaimed ? const Color(0xFF4C5458) : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18 * scale),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFFAF7) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: isSelected ? AppColors.mintPrimary.withValues(alpha: 0.6) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE0F4ED) : const Color(0xFFEAEAEA),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 22 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: Responsive.fs(context, 12),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: isSelected ? 1.05 : 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16 * scale),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: flashController,
                          builder: (context, child) {
                            final double progress = isFlashing ? flashController.value : 0;
                            final double opacity = (1 - (progress - 0.5).abs() * 2).clamp(0, 1);
                            final double alignX = -1 + (2 * progress);

                            if (opacity == 0) {
                              return const SizedBox.shrink();
                            }

                            return Align(
                              alignment: Alignment(alignX, 0),
                              child: Opacity(
                                opacity: opacity,
                                child: Container(
                                  width: 48 * scale,
                                  height: 36 * scale,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0x00FFFFFF),
                                        Color(0xCCFFFFFF),
                                        Color(0x00FFFFFF),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        blurRadius: 20 * scale,
                                        spreadRadius: 3 * scale,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                          decoration: BoxDecoration(
                            color: buttonColor,
                            borderRadius: BorderRadius.circular(14 * scale),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              buttonText,
                              key: ValueKey<String>(buttonText),
                              style: TextStyle(
                                color: buttonTextColor,
                                fontSize: Responsive.fs(context, 10),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
