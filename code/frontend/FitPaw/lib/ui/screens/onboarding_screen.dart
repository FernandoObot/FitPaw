import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../widgets/responsive.dart';
import 'sign_up_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = Responsive.scale(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.phoneWidth(context)),
            child: PageView(
              controller: _controller,
              onPageChanged: (value) => setState(() => _page = value),
              children: [
                _WelcomeOne(scale: scale, onStart: _next),
                _WelcomeTwo(scale: scale, onStart: _next),
                _InfoWelcome(
                  scale: scale,
                  title: 'Sigue tus metas',
                  subtitle:
                      'No te preocupes si te cuesta definir tus metas. Nosotros te ayudamos a establecerlas y a seguir tu progreso paso a paso.',
                  imageAsset: 'assets/images/onboarding_1.png',
                  fallbackIcon: Icons.fitness_center_rounded,
                  onNext: _next,
                ),
                _InfoWelcome(
                  scale: scale,
                  title: 'Manten el ritmo',
                  subtitle:
                      'Sigue quemando calorias para alcanzar tus metas. El dolor es solo temporal, pero si te rindes ahora, el arrepentimiento sera para siempre.',
                  imageAsset: 'assets/images/onboarding_2.png',
                  fallbackIcon: Icons.directions_run_rounded,
                  onNext: _goRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _next() {
    if (_page < 3) {
      _controller.nextPage(duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
    }
  }

  void _goRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
    );
  }
}

class _WelcomeOne extends StatelessWidget {
  const _WelcomeOne({required this.scale, required this.onStart});

  final double scale;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28 * scale, 22 * scale, 28 * scale, 18 * scale),
      child: Column(
        children: [
          const Spacer(),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: Responsive.fs(context, 42), fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              children: const [
                TextSpan(text: 'FIT'),
                TextSpan(text: 'PAW!', style: TextStyle(color: AppColors.mintPrimary)),
              ],
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            'Entrena acompanado, evoluciona juntos.',
            style: TextStyle(fontSize: Responsive.fs(context, 14), color: AppColors.faintText),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 54 * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(28 * scale)),
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
                child: Text('Empezar', style: TextStyle(fontSize: Responsive.fs(context, 16), color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeTwo extends StatelessWidget {
  const _WelcomeTwo({required this.scale, required this.onStart});

  final double scale;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(14 * scale, 16 * scale, 14 * scale, 14 * scale),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(28 * scale, 22 * scale, 28 * scale, 18 * scale),
        child: Column(
          children: [
            const Spacer(),
            RichText(
              text: TextSpan(
                style: TextStyle(fontSize: Responsive.fs(context, 42), fontWeight: FontWeight.w700, color: Colors.white),
                children: const [
                  TextSpan(text: 'FIT'),
                  TextSpan(text: 'PAW!', style: TextStyle(color: AppColors.deepNavy)),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Entrena acompanado, evoluciona juntos.',
              style: TextStyle(fontSize: Responsive.fs(context, 14), color: Colors.white.withValues(alpha: 0.75)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54 * scale,
              child: ElevatedButton(
                onPressed: onStart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28 * scale)),
                ),
                child: Text('Empezar', style: TextStyle(fontSize: Responsive.fs(context, 16), color: AppColors.deepNavy, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoWelcome extends StatelessWidget {
  const _InfoWelcome({
    required this.scale,
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.onNext,
  });

  final double scale;
  final String title;
  final String subtitle;
  final String imageAsset;
  final IconData fallbackIcon;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14 * scale, 16 * scale, 14 * scale, 14 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(22 * scale), topRight: Radius.circular(22 * scale), bottomLeft: Radius.circular(100 * scale)),
            child: SizedBox(
              height: 332 * scale,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: Icon(fallbackIcon, size: 112 * scale, color: Colors.white));
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 30 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18 * scale),
            child: Text(
              title,
              style: TextStyle(fontSize: Responsive.fs(context, 32), fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 12 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18 * scale),
            child: Text(
              subtitle,
              style: TextStyle(fontSize: Responsive.fs(context, 13), color: AppColors.textSecondary, height: 1.45),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: onNext,
              child: Container(
                width: 54 * scale,
                height: 54 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28 * scale),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
        ],
      ),
    );
  }
}
