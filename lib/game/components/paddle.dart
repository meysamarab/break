import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class Paddle extends BodyComponent {
  final Vector2 initialPosition;

  Paddle(this.initialPosition);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.kinematic,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBox(
      GameConstants.paddleWidth / 2,
      GameConstants.paddleHeight / 2,
      Vector2.zero(),
      0,
    );

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.1,
      restitution: 1.0,
    );

    body.createFixture(fixtureDef);
    return body;
  }

  void move(Vector2 delta) {
    final halfWidth = GameConstants.paddleWidth / 2;
    final newX = (body.position.x + delta.x).clamp(-20.0 + halfWidth, 20.0 - halfWidth);
    body.setTransform(Vector2(newX, body.position.y), 0);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameConstants.neonOrange
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = GameConstants.neonOrange.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: GameConstants.paddleWidth,
      height: GameConstants.paddleHeight,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), glowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)), paint);
  }
}
