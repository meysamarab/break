import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../brick_mania_game.dart';
import '../utils/constants.dart';

class HUD extends StatelessWidget {
  final BrickManiaGame game;

  const HUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level & Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DENSE-5',
                style: GoogleFonts.outfit(
                  color: GameConstants.neonCyan,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(color: GameConstants.neonCyan, blurRadius: 10),
                  ],
                ),
              ),
              ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (context, score, _) {
                  return Text(
                    'SCORE: $score',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Lives (Hearts) and Restart
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: game.lives,
                builder: (context, lives, _) {
                  return Row(
                    children: List.generate(3, (index) {
                      return Icon(
                        index < lives ? Icons.favorite : Icons.favorite_border,
                        color: GameConstants.neonMagenta,
                        size: 30,
                      );
                    }),
                  );
                },
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: game.restart,
                icon: const Icon(Icons.refresh, color: Colors.white, size: 30),
                tooltip: 'Restart',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
