import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../brick_mania_game.dart';
import '../utils/constants.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final BrickManiaGame game;

  const LevelCompleteOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
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
              'LEVEL COMPLETE',
              style: GoogleFonts.outfit(
                color: GameConstants.neonCyan,
                fontSize: 40,
                fontWeight: FontWeight.bold,
                shadows: [
                    const Shadow(color: GameConstants.neonCyan, blurRadius: 15),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SCORE: ${game.score.value}',
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: game.restart,
              style: ElevatedButton.styleFrom(
                backgroundColor: GameConstants.neonCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('NEXT LEVEL', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
