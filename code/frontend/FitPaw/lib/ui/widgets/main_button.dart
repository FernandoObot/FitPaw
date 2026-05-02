import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'responsive.dart';

class MainButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MainButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = 54 * Responsive.scale(context);
    final double buttonRadius = 25 * Responsive.scale(context);
    final double textSize = Responsive.fs(context, 17);

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.mintPrimary.withValues(alpha: 0.30),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: textSize),
        ),
      ),
    );
  }
}