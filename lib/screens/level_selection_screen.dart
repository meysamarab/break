import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/utils/constants.dart';
import '../providers/progress_provider.dart';
import '../main.dart'; // For GameScreen route

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);

    return Scaffold(
      backgroundColor: GameConstants.bgDeepPurple,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SELECT EPISODE',
          style: GameConstants.neonTextFont.copyWith(color: GameConstants.neonCyan),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameConstants.bgDeepPurple, GameConstants.bgNebula],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: 15, // Phase 2 requirement: 15+ levels
          itemBuilder: (context, index) {
            final level = index + 1;
            final isUnlocked = level <= progress.maxUnlockedLevel;
            final stars = progress.levelStars[level] ?? 0;

            return _buildLevelCard(context, level, isUnlocked, stars);
          },
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int level, bool isUnlocked, int stars) {
    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GameScreen(level: level)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? GameConstants.bgNebula.withOpacity(0.5) : Colors.black54,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUnlocked ? GameConstants.neonCyan : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [BoxShadow(color: GameConstants.neonCyan.withOpacity(0.3), blurRadius: 10)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              const Icon(Icons.lock, color: Colors.grey, size: 32)
            else ...[
              Text(
                level.toString(),
                style: GameConstants.neonTextFont.copyWith(
                  fontSize: 32,
                  color: Colors.white,
                  shadows: [Shadow(color: GameConstants.neonCyan, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < stars ? Icons.star : Icons.star_border,
                    color: index < stars ? GameConstants.neonGold : Colors.grey,
                    size: 16,
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
