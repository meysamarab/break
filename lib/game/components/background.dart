import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SpaceBackground extends Component with HasGameRef {
  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    
    // Draw background gradient
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GameConstants.bgDeepPurple,
          GameConstants.bgNebula,
        ],
      ).createShader(rect);
    
    canvas.drawRect(rect, paint);

    // Draw subtle nebula clouds
    final nebulaPaint = Paint()
      ..color = Colors.deepPurple.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50.0);
    
    canvas.drawCircle(Offset(size.x * 0.3, size.y * 0.4), 150, nebulaPaint);
    canvas.drawCircle(Offset(size.x * 0.7, size.y * 0.6), 200, nebulaPaint);

    // Draw stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.5);
    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.x, random.nextDouble() * size.y),
        random.nextDouble() * 1.5,
        starPaint,
      );
    }
  }
}
