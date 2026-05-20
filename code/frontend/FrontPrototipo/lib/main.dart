import 'package:flutter/material.dart';
import 'core/app_colors.dart';
import 'ui/screens/onboarding_screen.dart';
import 'services/app_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar el token guardado al iniciar
  await apiClient.loadToken();
  runApp(const FitPawApp());
}

class FitPawApp extends StatelessWidget {
  const FitPawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitPaw',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.softBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blueSecondary,
          brightness: Brightness.light,
        ),
        fontFamily: 'Segoe UI',
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}