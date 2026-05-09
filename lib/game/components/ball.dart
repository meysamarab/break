import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'brick.dart';
import 'paddle.dart';
import 'boundary.dart';

class Ball extends BodyComponent with ContactCallbacks {
  final Vector2 initialPosition;
  final List<Vector2> _trail = [];
  static const int _maxTrailPoints = 10;
  
  Ball(this.initialPosition);

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic,
      bullet: true,
      fixedRotation: true,
    );

    final body = world.createBody(bodyDef);

    final shape = CircleShape()..radius = GameConstants.ballRadius;
    
    final fixtureDef = FixtureDef(
      shape,
      restitution: 1.0,
      friction: 0.0,
      density: 1.0,
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Update trail
    _trail.add(body.position.clone());
    if (_trail.length > _maxTrailPoints) {
      _trail.removeAt(0);
    }

    // Velocity Cap
    final velocity = body.linearVelocity;
    if (velocity.length > GameConstants.ballSpeedCap) {
      body.linearVelocity = velocity.normalized() * GameConstants.ballSpeedCap;
    }

    // Ensure ball doesn't get stuck and always maintains a minimum speed
    if (velocity.length < GameConstants.ballInitialSpeed && velocity.length > 0) {
        body.linearVelocity = velocity.normalized() * GameConstants.ballInitialSpeed;
    }

  }

  @override
  void render(Canvas canvas) {
    // Render Trail
    final trailPaint = Paint()..color = GameConstants.neonCyan.withOpacity(0.3);
    for (int i = 0; i < _trail.length; i++) {
      final opacity = (i / _trail.length) * 0.3;
      trailPaint.color = GameConstants.neonCyan.withOpacity(opacity);
      canvas.drawCircle((_trail[i] - body.position).toOffset(), GameConstants.ballRadius * (i / _trail.length), trailPaint);
    }

    // Custom render for neon glow
    final paint = Paint()
      ..color = GameConstants.neonCyan
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4.0);
    
    final corePaint = Paint()..color = Colors.white;

    canvas.drawCircle(Offset.zero, GameConstants.ballRadius, paint);
    canvas.drawCircle(Offset.zero, GameConstants.ballRadius * 0.7, corePaint);
  }

  void launch() {
    body.linearVelocity = Vector2(0, -GameConstants.ballInitialSpeed);
  }


  @override
  void beginContact(Object other, Contact contact) {
    // Play hit sound for any contact
    FlameAudio.play('hit.mp3');

    if (other is Brick) {
      other.hit();
    }
    // Handle paddle angle reflection
    if (other is Paddle) {
        // We can tweak the velocity based on where it hit the paddle
        final paddlePos = other.body.position;
        final ballPos = body.position;
        final relativeX = ballPos.x - paddlePos.x;
        final normalizedRelativeX = relativeX / (GameConstants.paddleWidth / 2);
        
        final currentSpeed = body.linearVelocity.length;
        final newDir = Vector2(normalizedRelativeX * 3, -1).normalized();
        body.linearVelocity = newDir * max(currentSpeed, GameConstants.ballInitialSpeed);
    }
  }
}
