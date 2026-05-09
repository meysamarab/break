import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'paddle.dart';
import '../brick_mania_game.dart';

enum PowerUpType { multiBall, laser, magnet, gravity }

class PowerUp extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final PowerUpType type;

  PowerUp(this.initialPosition, this.type);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic,
      gravityOverride: Vector2(0, 5), // Slow fall
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = 0.5;
    
    final fixtureDef = FixtureDef(
      shape,
      isSensor: true,
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    final color = _getColor();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawCircle(Offset.zero, 0.5, glowPaint);
    canvas.drawCircle(Offset.zero, 0.5, paint);
    
    // Icon/Symbol
    final textPainter = TextPainter(
      text: TextSpan(
        text: _getSymbol(),
        style: const TextStyle(color: Colors.white, fontSize: 0.6, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
  }

  Color _getColor() {
    switch (type) {
      case PowerUpType.multiBall: return GameConstants.neonLime;
      case PowerUpType.laser: return GameConstants.neonMagenta;
      case PowerUpType.magnet: return Colors.purple;
      case PowerUpType.gravity: return GameConstants.neonGold;
    }
  }

  String _getSymbol() {
    switch (type) {
      case PowerUpType.multiBall: return '3x';
      case PowerUpType.laser: return 'L';
      case PowerUpType.magnet: return 'M';
      case PowerUpType.gravity: return 'G';
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Paddle) {
      (game as BrickManiaGame).onPowerUpCollected(this);
      removeFromParent();
    }
  }
}
