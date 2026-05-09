import 'package:flutter/material.dart';
import '../game/utils/constants.dart';
import 'level_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConstants.bgDeepPurple,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameConstants.bgDeepPurple, GameConstants.bgNebula],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                'BRICK MANIA',
                style: GameConstants.neonTextFont.copyWith(
                  fontSize: 54,
                  color: GameConstants.neonCyan,
                  shadows: [Shadow(color: GameConstants.neonCyan, blurRadius: 20)],
                ),
              ),
              Text(
                'ANTI-GRAVITY',
                style: GameConstants.neonTextFont.copyWith(
                  fontSize: 20,
                  color: GameConstants.neonMagenta,
                  letterSpacing: 6,
                  shadows: [Shadow(color: GameConstants.neonMagenta, blurRadius: 10)],
                ),
              ),
              const Spacer(),
              _buildMenuButton(context, 'PLAY', GameConstants.neonLime, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LevelSelectionScreen()),
                );
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'SHOP', GameConstants.neonOrange, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shop coming soon!')),
                );
              }),
              const SizedBox(height: 20),
              _buildMenuButton(context, 'SETTINGS', GameConstants.neonBlue, () {}),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GameConstants.neonTextFont.copyWith(
              fontSize: 28,
              color: Colors.white,
              shadows: [Shadow(color: color, blurRadius: 10)],
            ),
          ),
        ),
      ),
    );
  }
}
