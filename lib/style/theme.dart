import 'dart:ui';
import 'package:flutter/cupertino.dart';

class Colors {
  const Colors();

  static const Color loginGradientStart = Color(0xFFAB96D4);
  static const Color loginGradientEnd = Color(0xFFf7418c); // Color(0xFFff8a9a);

  static const primaryGradient = LinearGradient(
    colors: [loginGradientStart, loginGradientEnd],
    stops: [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
