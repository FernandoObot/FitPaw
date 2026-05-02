import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'home_dashboard_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedAccountIndex = 0;
  bool _selectedOther = false;
  bool _enablePopups = true;
  bool _disableNotifications = false;
  int _selectedBottomIndex = 4;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context) * 1.06;

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
                            'Perfil',
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
                    padding: EdgeInsets.fromLTRB(20 * scale, 8 * scale, 20 * scale, 18 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52 * scale,
                              height: 52 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppColors.primaryGradient,
                              ),
                              child: Icon(Icons.person_rounded, color: Colors.white, size: 26 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jonathan',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: Responsive.fs(context, 18),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4 * scale),
                                  Text(
                                    'Perder grasa',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: Responsive.fs(context, 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 32 * scale,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8EE596),
                                  padding: EdgeInsets.symmetric(horizontal: 18 * scale),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Editar',
                                  style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 12), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * scale),
                        Row(
                          children: [
                            Expanded(child: _MetricCard(label: 'Estatura', value: '170cm')),
                            SizedBox(width: 10 * scale),
                            Expanded(child: _MetricCard(label: 'Peso', value: '65kg')),
                            SizedBox(width: 10 * scale),
                            Expanded(child: _MetricCard(label: 'Edad', value: '21')),
                          ],
                        ),
                        SizedBox(height: 16 * scale),
                        _SectionCard(
                          title: 'Cuenta',
                          child: Column(
                            children: [
                              _OptionTile(
                                icon: Icons.person_outline_rounded,
                                label: 'Informacion Personal',
                                isSelected: _selectedAccountIndex == 0,
                                onTap: () => _setAccountSelection(0),
                              ),
                              _OptionTile(
                                icon: Icons.calendar_month_outlined,
                                label: 'Historial de actividades',
                                isSelected: _selectedAccountIndex == 1,
                                onTap: () => _setAccountSelection(1),
                              ),
                              _OptionTile(
                                icon: Icons.bar_chart_rounded,
                                label: 'Progreso personal',
                                isSelected: _selectedAccountIndex == 2,
                                onTap: () => _setAccountSelection(2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        _SectionCard(
                          title: 'Notificaciones',
                          child: Column(
                            children: [
                              _SwitchTile(
                                label: 'Pop-up de notificaciones',
                                value: _enablePopups,
                                onChanged: (value) => setState(() => _enablePopups = value),
                              ),
                              _SwitchTile(
                                label: 'Desactivar notificaciones',
                                value: _disableNotifications,
                                onChanged: (value) => setState(() => _disableNotifications = value),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        _SectionCard(
                          title: 'Otros',
                          child: _OptionTile(
                            icon: Icons.settings_outlined,
                            label: 'Ajustes',
                            isSelected: _selectedOther,
                            onTap: () => setState(() => _selectedOther = !_selectedOther),
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                      ],
                    ),
                  ),
                ),
                _BottomNavBar(
                  selectedIndex: _selectedBottomIndex,
                  onTap: _handleBottomTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setAccountSelection(int index) {
    setState(() => _selectedAccountIndex = index);
  }

  void _handleBottomTap(int index) {
    setState(() => _selectedBottomIndex = index);

    if (index == 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        );
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.mintPrimary,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fs(context, 15),
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: Responsive.fs(context, 11),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16 * scale, 14 * scale, 16 * scale, 10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(18 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: Responsive.fs(context, 15),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          child,
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14 * scale),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : const Color(0xFFFFF7F7),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(
                color: isSelected ? AppColors.mintPrimary.withValues(alpha: 0.6) : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.mintPrimary, size: 18 * scale),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: Responsive.fs(context, 12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isSelected ? 1 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.mintPrimary,
                    size: 18 * scale,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 18 * scale,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.fs(context, 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.mintPrimary,
            inactiveTrackColor: const Color(0xFFD8EDE7),
          ),
        ],
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      height: 88 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFF4EEEF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomBarIcon(
            icon: Icons.home_rounded,
            isActive: selectedIndex == 0,
            scale: scale,
            onTap: () => onTap(0),
          ),
          _BottomBarIcon(
            icon: Icons.query_stats_rounded,
            isActive: selectedIndex == 1,
            scale: scale,
            onTap: () => onTap(1),
          ),
          _BottomBarIcon(
            icon: Icons.search_rounded,
            isActive: selectedIndex == 2,
            scale: scale,
            isPrimary: true,
            onTap: () => onTap(2),
          ),
          _BottomBarIcon(
            icon: Icons.camera_alt_outlined,
            isActive: selectedIndex == 3,
            scale: scale,
            onTap: () => onTap(3),
          ),
          _BottomBarIcon(
            icon: Icons.person_outline_rounded,
            isActive: selectedIndex == 4,
            scale: scale,
            onTap: () => onTap(4),
          ),
        ],
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
            child: Icon(Icons.search_rounded, color: Colors.white, size: 30 * scale),
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
