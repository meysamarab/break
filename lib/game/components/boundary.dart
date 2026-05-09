import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import '../brick_mania_game.dart';

class Boundary extends BodyComponent with ContactCallbacks {
  final Vector2 start;
  final Vector2 end;
  final bool isBottom;

  Boundary(this.start, this.end, {this.isBottom = false});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.zero(),
      type: BodyType.static,
    );

    final body = world.createBody(bodyDef);

    final shape = EdgeShape()..set(start, end);
    
    final fixtureDef = FixtureDef(
      shape,
      friction: 0.1,
      restitution: 1.0,
    );

    body.createFixture(fixtureDef);
    return body;
  }

  @override
  void render(Canvas canvas) {
    // Usually invisible, but we can add a neon edge glow
    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.2)
      ..strokeWidth = 0.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    canvas.drawLine(start.toOffset(), end.toOffset(), paint);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (isBottom && other is BodyComponent) {
      (game as BrickManiaGame).onBallLost(other);
    }
  }
}
