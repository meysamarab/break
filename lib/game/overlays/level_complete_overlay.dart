import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../brick_mania_game.dart';
import '../utils/constants.dart';
import '../../providers/progress_provider.dart';
import '../../screens/main_menu_screen.dart';

class LevelCompleteOverlay extends ConsumerStatefulWidget {
  final BrickManiaGame game;

  const LevelCompleteOverlay({super.key, required this.game});

  @override
  ConsumerState<LevelCompleteOverlay> createState() => _LevelCompleteOverlayState();
}

class _LevelCompleteOverlayState extends ConsumerState<LevelCompleteOverlay> {
  int stars = 0;
  int earnedCrystals = 0;

  @override
  void initState() {
    super.initState();
    _calculateAndSaveProgress();
  }

  void _calculateAndSaveProgress() {
    // Calculate stars based on lives remaining and score
    if (widget.game.lives.value == 3) {
      stars = 3;
    } else if (widget.game.lives.value == 2) {
      stars = 2;
    } else {
      stars = 1;
    }

    earnedCrystals = stars * 10 + (widget.game.score.value ~/ 100);

    // Save progress after a short delay to avoid build phase issues
    Future.microtask(() {
      ref.read(progressProvider.notifier).updateLevelProgress(
        widget.game.levelId,
        stars,
        earnedCrystals,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GameConstants.neonCyan, width: 2),
          boxShadow: [
            BoxShadow(color: GameConstants.neonCyan.withOpacity(0.3), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LEVEL CLEARED',
              style: GameConstants.neonTextFont.copyWith(
                color: GameConstants.neonCyan,
                fontSize: 32,
                shadows: [const Shadow(color: GameConstants.neonCyan, blurRadius: 15)],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Icon(
                  index < stars ? Icons.star : Icons.star_border,
                  color: index < stars ? GameConstants.neonGold : Colors.grey,
                  size: 48,
                );
              }),
            ),
            const SizedBox(height: 20),
            Text(
              'SCORE: ${widget.game.score.value}',
              style: GameConstants.neonTextFont.copyWith(color: Colors.white, fontSize: 24),
            ),
            Text(
              '+$earnedCrystals Crystals',
              style: GameConstants.neonTextFont.copyWith(color: GameConstants.neonLime, fontSize: 18),
            ),
            const SizedBox(height: 30),
            _buildButton('MAIN MENU', GameConstants.neonMagenta, () {
              widget.game.resumeEngine(); // Ensure engine is running before leaving
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainMenuScreen()),
                (Route<dynamic> route) => false,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GameConstants.neonTextFont.copyWith(
              fontSize: 20,
              color: Colors.white,
              shadows: [Shadow(color: color, blurRadius: 10)],
            ),
          ),
        ),
      ),
    );
  }
}
