import 'dart:math' as math;
import 'package:flame/events.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'components/ball.dart';
import 'components/paddle.dart';
import 'components/brick.dart';
import 'components/boundary.dart';
import 'components/background.dart';
import 'components/power_up.dart';
import 'components/brick_explosion.dart';
import 'utils/constants.dart';
import 'package:vibration/vibration.dart';

class BrickManiaGame extends Forge2DGame with DragCallbacks {
  late Paddle paddle;
  late Ball ball;
  
  final ValueNotifier<int> score = ValueNotifier<int>(0);
  final ValueNotifier<int> lives = ValueNotifier<int>(3);
  int bricksRemaining = 0;
  bool isGameOver = false;
  bool isLevelComplete = false;

  BrickManiaGame() : super(
    gravity: Vector2(0, 0),
    camera: CameraComponent.withFixedResolution(width: 800, height: 1600),
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Configure camera viewfinder
    camera.viewfinder.zoom = 20.0;
    camera.viewfinder.anchor = Anchor.center;

    // Add background to the camera backdrop so it isn't affected by world zoom
    camera.backdrop.add(SpaceBackground());

    // Fixed World Boundaries (-20 to 20 horizontally, -40 to 40 vertically)
    final topLeft = Vector2(-20, -40);
    final topRight = Vector2(20, -40);
    final bottomLeft = Vector2(-20, 40);
    final bottomRight = Vector2(20, 40);

    add(Boundary(topLeft, topRight)); // Top
    add(Boundary(topLeft, bottomLeft)); // Left
    add(Boundary(topRight, bottomRight)); // Right
    add(Boundary(bottomLeft, bottomRight, isBottom: true)); // Bottom (Loss)

    // Add Paddle
    paddle = Paddle(Vector2(0, 35)); // Near the bottom (40 is bottom edge)
    await add(paddle);

    // Add Ball
    await resetBall();

    // Generate Level: Dense-5
    _generateDense5Level();
  }

  Future<void> resetBall() async {
    ball = Ball(Vector2(0, paddle.body.position.y - 1));
    await add(ball);
    ball.launch();
  }

  void _generateDense5Level() {
    const double startY = -25; // Adjusted for new -40 top boundary
    const int rows = 6;
    const int cols = 9;
    
    final colors = [
      GameConstants.neonCyan,
      GameConstants.neonMagenta,
      GameConstants.neonBlue,
      GameConstants.neonLime,
      GameConstants.neonOrange,
      GameConstants.neonGold,
    ];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = (c - (cols - 1) / 2) * (GameConstants.brickWidth + GameConstants.brickPadding);
        final y = startY + r * (GameConstants.brickHeight + GameConstants.brickPadding);
        
        BrickType type = BrickType.normal;
        double rand = math.Random().nextDouble();
        if (rand < 0.05) {
          type = BrickType.moving;
        } else if (rand < 0.15) {
          type = BrickType.explosive;
        } else if (rand < 0.3) {
          type = BrickType.durable;
        }
        
        final brick = Brick(
          position: Vector2(x, y),
          type: type,
          color: colors[r % colors.length],
        );
        add(brick);
        bricksRemaining++;
      }
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    paddle.move(event.localDelta / 20); // Adjust sensitivity
  }

  void onBrickDestroyed(Brick brick) {
    score.value += (brick.type == BrickType.durable ? 100 : 50);
    bricksRemaining--;
    
    // Visual Polish: Particle Explosion
    add(BrickExplosion(position: brick.body.position, color: brick.color));
    
    // Haptic Feedback
    Vibration.vibrate(duration: 50, amplitude: 128);

    // Explosive logic
    if (brick.type == BrickType.explosive) {
      final adjacentBricks = children.whereType<Brick>().where((b) {
        if (b == brick || b.isRemoving) return false;
        return b.body.position.distanceTo(brick.body.position) < (GameConstants.brickWidth * 1.5);
      }).toList();
      for (final b in adjacentBricks) {
        b.hit();
      }
    }

    // Chance to drop power-up
    if (math.Random().nextDouble() < 0.15) {
        final types = PowerUpType.values;
        final type = types[math.Random().nextInt(types.length)];
        add(PowerUp(brick.body.position.clone(), type));
    }

    if (bricksRemaining <= 0) {
      completeLevel();
    }
  }

  Future<void> onBallLost(Object ballObj) async {
    if (ballObj is Ball) {
      ballObj.removeFromParent();
      lives.value--;
      if (lives.value <= 0) {
        gameOver();
      } else {
        await resetBall();
      }
    }
  }

  Future<void> onPowerUpCollected(PowerUp powerUp) async {
    score.value += 200;
    
    if (powerUp.type == PowerUpType.multiBall) {
      final b1 = Ball(Vector2(paddle.body.position.x - 1, paddle.body.position.y - 1));
      final b2 = Ball(Vector2(paddle.body.position.x + 1, paddle.body.position.y - 1));
      await add(b1);
      await add(b2);
      b1.body.applyLinearImpulse(Vector2(-5, -GameConstants.ballInitialVelocity));
      b2.body.applyLinearImpulse(Vector2(5, -GameConstants.ballInitialVelocity));
    }
    // Other power-ups can be added here
  }

  void gameOver() {
    isGameOver = true;
    pauseEngine();
    overlays.add('GameOver');
  }

  void completeLevel() {
    isLevelComplete = true;
    pauseEngine();
    overlays.add('LevelComplete');
  }

  Future<void> restart() async {
    score.value = 0;
    lives.value = 3;
    isGameOver = false;
    isLevelComplete = false;
    bricksRemaining = 0;
    
    // Clear existing components
    children.whereType<Brick>().forEach((b) => b.removeFromParent());
    children.whereType<Ball>().forEach((b) => b.removeFromParent());
    children.whereType<PowerUp>().forEach((b) => b.removeFromParent());
    
    // Re-generate
    _generateDense5Level();
    await resetBall();
    
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    resumeEngine();
  }
}
