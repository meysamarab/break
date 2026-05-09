import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../brick_mania_game.dart';

enum BrickType { normal, durable, explosive, moving }

class Brick extends BodyComponent {
  final Vector2 position;
  final BrickType type;
  int health;
  final Color color;

  Brick({
    required this.position,
    required this.type,
    required this.color,
  }) : health = (type == BrickType.durable ? 2 : 1);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: type == BrickType.moving ? BodyType.kinematic : BodyType.static,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape();
    shape.setAsBox(
      GameConstants.brickWidth / 2,
      GameConstants.brickHeight / 2,
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

  double _moveDirection = 1.0;
  static const double _moveSpeed = 3.0;
  static const double _moveRange = 4.0;

  @override
  void update(double dt) {
    super.update(dt);
    if (type == BrickType.moving) {
      if (body.position.x > position.x + _moveRange) {
        _moveDirection = -1.0;
      } else if (body.position.x < position.x - _moveRange) {
        _moveDirection = 1.0;
      }
      body.linearVelocity = Vector2(_moveDirection * _moveSpeed, 0);
    }
  }

  void hit() {
    health--;
    if (health <= 0) {
      removeFromParent();
      (game as BrickManiaGame).onBrickDestroyed(this);
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: GameConstants.brickWidth,
      height: GameConstants.brickHeight,
    );

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), glowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
    
    // Add holographic effect lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.1;
    
    for (double i = -GameConstants.brickWidth/2; i < GameConstants.brickWidth/2; i += 0.8) {
        canvas.drawLine(Offset(i, -GameConstants.brickHeight/2), Offset(i + 0.5, GameConstants.brickHeight/2), linePaint);
    }
  }
}
