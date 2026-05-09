import 'package:flutter/material.dart';
import '../brick_mania_game.dart';
import '../utils/constants.dart';
import '../../screens/main_menu_screen.dart';

class PauseOverlay extends StatelessWidget {
  final BrickManiaGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GameConstants.neonBlue, width: 2),
          boxShadow: [
            BoxShadow(color: GameConstants.neonBlue.withOpacity(0.5), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PAUSED',
              style: GameConstants.neonTextFont.copyWith(
                fontSize: 36,
                color: GameConstants.neonBlue,
                shadows: [Shadow(color: GameConstants.neonBlue, blurRadius: 10)],
              ),
            ),
            const SizedBox(height: 30),
            _buildButton('RESUME', GameConstants.neonLime, () {
              game.resumeGame();
            }),
            const SizedBox(height: 15),
            _buildButton('RESTART', GameConstants.neonOrange, () {
              game.resumeGame();
              game.restart();
            }),
            const SizedBox(height: 15),
            _buildButton('MAIN MENU', GameConstants.neonMagenta, () {
              game.resumeEngine();
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
