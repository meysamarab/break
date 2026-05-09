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
  final int levelId;

  BrickManiaGame({this.levelId = 1}) : super(
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

    world.add(Boundary(topLeft, topRight)); // Top
    world.add(Boundary(topLeft, bottomLeft)); // Left
    world.add(Boundary(topRight, bottomRight)); // Right
    world.add(Boundary(bottomLeft, bottomRight, isBottom: true)); // Bottom (Loss)

    // Add Paddle
    paddle = Paddle(Vector2(0, 35)); // Near the bottom (40 is bottom edge)
    await world.add(paddle);

    // Add Ball
    await resetBall();

    // Generate Level
    _generateLevel();
  }


  Future<void> resetBall() async {
    ball = Ball(Vector2(0, paddle.body.position.y - 1));
    await world.add(ball);
    ball.launch();
  }

  void _generateLevel() {
    const double startY = -25;
    
    // Scale level difficulty by levelId
    final int rows = math.min(3 + (levelId ~/ 3), 8); // Max 8 rows
    final int cols = 9;
    
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
        // Leave some empty spaces for higher levels
        if (levelId > 5 && math.Random().nextDouble() < 0.1) continue;

        final x = (c - (cols - 1) / 2) * (GameConstants.brickWidth + GameConstants.brickPadding);
        final y = startY + r * (GameConstants.brickHeight + GameConstants.brickPadding);
        
        BrickType type = BrickType.normal;
        double rand = math.Random().nextDouble();
        
        // Difficulty scaling
        double movingChance = math.min(0.02 * levelId, 0.15);
        double explosiveChance = math.min(0.05 + 0.01 * levelId, 0.2);
        double durableChance = math.min(0.1 + 0.02 * levelId, 0.4);

        if (rand < movingChance) {
          type = BrickType.moving;
        } else if (rand < movingChance + explosiveChance) {
          type = BrickType.explosive;
        } else if (rand < movingChance + explosiveChance + durableChance) {
          type = BrickType.durable;
        }
        
        final brick = Brick(
          position: Vector2(x, y),
          type: type,
          color: colors[r % colors.length],
        );
        world.add(brick);
        bricksRemaining++;
      }
    }
  }


  @override
  void onDragUpdate(DragUpdateEvent event) {
    paddle.move(event.localDelta / 5); // Adjust sensitivity
  }

  void onBrickDestroyed(Brick brick) {
    score.value += (brick.type == BrickType.durable ? 100 : 50);
    bricksRemaining--;
    
    // Visual Polish: Particle Explosion
    world.add(BrickExplosion(position: brick.body.position, color: brick.color));
    
    // Haptic Feedback
    Vibration.vibrate(duration: 50, amplitude: 128);

    // Explosive logic
    if (brick.type == BrickType.explosive) {
      final adjacentBricks = world.children.whereType<Brick>().where((b) {
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
        world.add(PowerUp(brick.body.position.clone(), type));
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
      await world.add(b1);
      await world.add(b2);
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

  void pauseGame() {
    pauseEngine();
    overlays.add('Pause');
  }

  void resumeGame() {
    overlays.remove('Pause');
    resumeEngine();
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
    world.children.whereType<Brick>().forEach((b) => b.removeFromParent());
    world.children.whereType<Ball>().forEach((b) => b.removeFromParent());
    world.children.whereType<PowerUp>().forEach((b) => b.removeFromParent());
    
    // Re-generate
    _generateLevel();
    await resetBall();

    
    overlays.remove('GameOver');
    overlays.remove('LevelComplete');
    resumeEngine();
  }
}
