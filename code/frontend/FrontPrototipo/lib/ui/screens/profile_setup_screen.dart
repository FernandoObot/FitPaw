import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../widgets/responsive.dart';
import 'goal_picker_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late AuthService authService;
  final TextEditingController generoController = TextEditingController();
  final TextEditingController anoNacimientoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController estaturaController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    authService = AuthService(ApiClient());
  }

  @override
  void dispose() {
    generoController.dispose();
    anoNacimientoController.dispose();
    pesoController.dispose();
    estaturaController.dispose();
    super.dispose();
  }

  Future<void> _guardarPerfil() async {
    // Validar que los campos no estén vacíos
    if (generoController.text.isEmpty ||
        anoNacimientoController.text.isEmpty ||
        pesoController.text.isEmpty ||
        estaturaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Convertir año a fecha (asumiendo el 1 de enero del año ingresado)
      final ano = int.parse(anoNacimientoController.text);
      final fechaNacimiento = DateTime(ano, 1, 1);
      final peso = double.parse(pesoController.text);
      final estatura = int.parse(estaturaController.text);

      final result = await authService.updateProfile(
        genero: generoController.text,
        fechaNacimiento: fechaNacimiento,
        pesoActual: peso,
        estaturaCm: estatura,
      );

      if (result['success']) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const GoalPickerScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['error']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _mostrarSelectorGenero() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecciona tu género'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Masculino', 'Femenino', 'Otro']
              .map((genero) => ListTile(
                    title: Text(genero),
                    onTap: () {
                      generoController.text = genero;
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

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
                        _ProfileField(
                          controller: generoController,
                          hint: 'Selecciona tu genero',
                          icon: Icons.person_2_outlined,
                          hasDropdown: true,
                          onTap: _mostrarSelectorGenero,
                        ),
                        SizedBox(height: 12 * scale),
                        _ProfileField(
                          controller: anoNacimientoController,
                          hint: 'Ano de nacimiento',
                          icon: Icons.calendar_month_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 12 * scale),
                        _TwoMetricRow(
                          scale: scale,
                          left: 'Peso',
                          rightLabel: 'KG',
                          leftIcon: Icons.monitor_weight_outlined,
                          controller: pesoController,
                        ),
                        SizedBox(height: 12 * scale),
                        _TwoMetricRow(
                          scale: scale,
                          left: 'Estatura',
                          rightLabel: 'CM',
                          leftIcon: Icons.height_outlined,
                          controller: estaturaController,
                        ),
                        SizedBox(height: 24 * scale),
                        SizedBox(
                          width: double.infinity,
                          height: 56 * scale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(30 * scale)),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _guardarPerfil,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                              child: isLoading
                                  ? SizedBox(
                                      height: 24 * scale,
                                      width: 24 * scale,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
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
  const _ProfileField({
    required this.hint,
    required this.icon,
    this.hasDropdown = false,
    this.controller,
    this.onTap,
    this.keyboardType = TextInputType.text,
  });

  final String hint;
  final IconData icon;
  final bool hasDropdown;
  final TextEditingController? controller;
  final VoidCallback? onTap;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: hasDropdown,
      keyboardType: keyboardType,
      onTap: onTap,
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
  const _TwoMetricRow({
    required this.scale,
    required this.left,
    required this.rightLabel,
    required this.leftIcon,
    this.controller,
  });

  final double scale;
  final String left;
  final String rightLabel;
  final IconData leftIcon;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileField(
            controller: controller,
            hint: left,
            icon: leftIcon,
            keyboardType: TextInputType.number,
          ),
        ),
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
