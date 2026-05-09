import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'game/brick_mania_game.dart';
import 'game/overlays/hud.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/level_complete_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set portrait orientation and full screen
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(
    const ProviderScope(
      child: BrickManiaApp(),
    ),
  );
}

class BrickManiaApp extends StatelessWidget {
  const BrickManiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brick Mania: Anti-Gravity',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final BrickManiaGame game;

  @override
  void initState() {
    super.initState();
    game = BrickManiaGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<BrickManiaGame>(
        game: game,
        overlayBuilderMap: {
          'HUD': (context, game) => HUD(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
          'LevelComplete': (context, game) => LevelCompleteOverlay(game: game),
        },
        initialActiveOverlays: const ['HUD'],
      ),
    );
  }
}
