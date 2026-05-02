import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class NextStepButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NextStepButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient, // Tu degradado menta
          boxShadow: [
            BoxShadow(
              color: AppColors.mintPrimary.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.chevron_right, color: Colors.white, size: 35),
      ),
    );
  }
}