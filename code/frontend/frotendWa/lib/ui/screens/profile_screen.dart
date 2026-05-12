import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import 'activity_history_screen.dart';
import 'camera_screen.dart';
import 'home_dashboard_screen.dart';
import 'pet_screen.dart';
import 'sign_in_screen.dart';
import 'progress_screen.dart';
import 'training_schedule_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedAccountIndex = 0;
  bool _selectedOther = false;
  int _selectedBottomIndex = 4;
  bool _isEditingProfile = false;

  late final AuthService _authService;

  late final TextEditingController _nameController;
  late final TextEditingController _goalController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _ageController;

  String _profileName = 'Jonathan';
  String _profileGoal = 'Perder grasa';
  String _profileHeight = '170 cm';
  String _profileWeight = '65 kg';
  String _profileAge = '21';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileName);
    _goalController = TextEditingController(text: _profileGoal);
    _heightController = TextEditingController(text: _profileHeight.replaceAll(' cm', ''));
    _weightController = TextEditingController(text: _profileWeight.replaceAll(' kg', ''));
    _ageController = TextEditingController(text: _profileAge);
    _authService = AuthService(ApiClient());
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

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
                                  if (!_isEditingProfile) ...[
                                    Text(
                                      _profileName,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: Responsive.fs(context, 18),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      _profileGoal,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: Responsive.fs(context, 12),
                                      ),
                                    ),
                                  ] else ...[
                                    TextField(
                                      controller: _nameController,
                                      decoration: const InputDecoration(
                                        hintText: 'Nombre',
                                        isDense: true,
                                      ),
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: Responsive.fs(context, 18),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    TextField(
                                      controller: _goalController,
                                      decoration: const InputDecoration(
                                        hintText: 'Objetivo',
                                        isDense: true,
                                      ),
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: Responsive.fs(context, 12),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 32 * scale,
                              child: _isEditingProfile
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _saveProfileEdits,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF8EE596),
                                            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
                                            elevation: 0,
                                          ),
                                          child: Text(
                                            'Guardar',
                                            style: TextStyle(color: Colors.white, fontSize: Responsive.fs(context, 12), fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(width: 8 * scale),
                                        OutlinedButton(
                                          onPressed: _cancelProfileEdits,
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(horizontal: 14 * scale),
                                            side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
                                          ),
                                          child: Text(
                                            'Cancelar',
                                            style: TextStyle(color: AppColors.textSecondary, fontSize: Responsive.fs(context, 12), fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    )
                                  : ElevatedButton(
                                      onPressed: _startProfileEdit,
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
                            Expanded(
                              child: _isEditingProfile
                                  ? _MetricInputCard(
                                      label: 'Estatura',
                                      controller: _heightController,
                                      suffix: 'cm',
                                    )
                                  : _MetricCard(label: 'Estatura', value: _profileHeight),
                            ),
                            SizedBox(width: 10 * scale),
                            Expanded(
                              child: _isEditingProfile
                                  ? _MetricInputCard(
                                      label: 'Peso',
                                      controller: _weightController,
                                      suffix: 'kg',
                                    )
                                  : _MetricCard(label: 'Peso', value: _profileWeight),
                            ),
                            SizedBox(width: 10 * scale),
                            Expanded(
                              child: _MetricCard(label: 'Edad', value: _profileAge),
                            ),
                          ],
                        ),
                        SizedBox(height: 16 * scale),
                        _SectionCard(
                          title: 'Cuenta',
                          child: Column(
                            children: [
                              _OptionTile(
                                icon: Icons.calendar_month_outlined,
                                label: 'Historial de actividades',
                                isSelected: _selectedAccountIndex == 0,
                                onTap: () {
                                  setState(() => _selectedAccountIndex = 0);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                                  );
                                },
                              ),
                              _OptionTile(
                                icon: Icons.bar_chart_rounded,
                                label: 'Progreso personal',
                                isSelected: _selectedAccountIndex == 1,
                                onTap: () {
                                  setState(() => _selectedAccountIndex = 1);
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        _SectionCard(
                          title: 'Otros',
                          child: Column(
                            children: [
                              _OptionTile(
                                icon: Icons.settings_outlined,
                                label: 'Ajustes',
                                isSelected: _selectedOther,
                                onTap: () => setState(() => _selectedOther = !_selectedOther),
                              ),
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Padding(
                                  padding: EdgeInsets.only(top: 8 * scale),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 44 * scale,
                                    child: OutlinedButton.icon(
                                      onPressed: _goToSignIn,
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: const Color(0xFFFF6A6A).withValues(alpha: 0.35)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                                        backgroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF6A6A)),
                                      label: Text(
                                        'Cerrar sesión',
                                        style: TextStyle(
                                          color: const Color(0xFFFF6A6A),
                                          fontSize: Responsive.fs(context, 13),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                crossFadeState: _selectedOther ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 180),
                              ),
                            ],
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

  void _goToSignIn() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _startProfileEdit() {
    setState(() {
      _isEditingProfile = true;
      _nameController.text = _profileName;
      _goalController.text = _profileGoal;
      _heightController.text = _profileHeight.replaceAll(' cm', '');
      _weightController.text = _profileWeight.replaceAll(' kg', '');
      _ageController.text = _profileAge;
    });
  }

  void _cancelProfileEdits() {
    setState(() {
      _isEditingProfile = false;
      _nameController.text = _profileName;
      _goalController.text = _profileGoal;
      _heightController.text = _profileHeight.replaceAll(' cm', '');
      _weightController.text = _profileWeight.replaceAll(' kg', '');
      _ageController.text = _profileAge;
    });
  }

  Future<void> _saveProfileEdits() async {
    final newName = _nameController.text.trim();
    final newHeightText = _heightController.text.trim();
    final newWeightText = _weightController.text.trim();

    double? weight;
    int? height;
    if (newWeightText.isNotEmpty) {
      weight = double.tryParse(newWeightText);
    }
    if (newHeightText.isNotEmpty) {
      height = int.tryParse(newHeightText);
    }

    try {
      final result = await _authService.editProfile(
        nombreCompleto: newName.isEmpty ? null : newName,
        pesoActual: weight,
        estaturaCm: height,
      );

      if (result['success']) {
        if (!mounted) return;
        setState(() {
          if (newName.isNotEmpty) _profileName = newName;
          if (newHeightText.isNotEmpty && height != null) _profileHeight = '${height} cm';
          if (newWeightText.isNotEmpty && weight != null) _profileWeight = '${weight.toString()} kg';
          _profileGoal = _goalController.text.trim().isEmpty ? _profileGoal : _goalController.text.trim();
          _isEditingProfile = false;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _loadProfile() async {
    try {
      final result = await _authService.getProfile();
      if (result['success']) {
        final data = result['data'] as Map<String, dynamic>;
        setState(() {
          _profileName = data['nickname'] ?? _profileName;
          _profileGoal = data['objetivoPrincipal'] ?? _profileGoal;
          if (data['estaturaCm'] != null) _profileHeight = '${data['estaturaCm']} cm';
          if (data['pesoActual'] != null) _profileWeight = '${data['pesoActual'].toString()} kg';
          if (data['fechaNacimiento'] != null) {
            try {
              final fecha = DateTime.parse(data['fechaNacimiento']);
              final now = DateTime.now();
              final edad = now.year - fecha.year - ((now.month < fecha.month || (now.month == fecha.month && now.day < fecha.day)) ? 1 : 0);
              _profileAge = edad.toString();
            } catch (_) {}
          }
          // update controllers
          _nameController.text = _profileName;
          _goalController.text = _profileGoal;
          _heightController.text = _profileHeight.replaceAll(' cm', '');
          _weightController.text = _profileWeight.replaceAll(' kg', '');
          _ageController.text = _profileAge;
        });
      }
    } catch (e) {
      // ignore loading errors silently for now
    }
  }

  void _handleBottomTap(int index) {
    setState(() => _selectedBottomIndex = index);

    if (index == 0) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        (route) => false,
      );
    } else if (index == 1) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TrainingScheduleScreen(
            exerciseTitle: 'Programa de entrenamiento',
            exerciseSubtitle: 'Tu plan personalizado',
            exerciseIcon: Icons.query_stats_rounded,
          )))
          .then((_) => setState(() => _selectedBottomIndex = 4));
    } else if (index == 2) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PetScreen()))
          .then((_) => setState(() => _selectedBottomIndex = 4));
    } else if (index == 3) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CameraScreen()))
          .then((_) => setState(() => _selectedBottomIndex = 4));
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

class _MetricInputCard extends StatelessWidget {
  const _MetricInputCard({
    required this.label,
    required this.controller,
    required this.suffix,
  });

  final String label;
  final TextEditingController controller;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.mintPrimary.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              suffixText: suffix.isEmpty ? null : suffix,
              suffixStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: Responsive.fs(context, 12),
                fontWeight: FontWeight.w600,
              ),
            ),
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
            icon: Icons.pets_rounded,
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
