import 'dart:math' as math;

import 'package:flutter/widgets.dart';

class Responsive {
  static double phoneWidth(BuildContext context, {double max = 430}) {
    final double width = MediaQuery.sizeOf(context).width;
    return math.min(width, max);
  }

  static double scale(BuildContext context, {double baseWidth = 390}) {
    final double width = phoneWidth(context, max: 600);
    return (width / baseWidth).clamp(0.86, 1.18);
  }

  static double fs(BuildContext context, double size) {
    return size * scale(context);
  }
}
