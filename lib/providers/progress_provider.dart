import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserProgress {
  final int maxUnlockedLevel;
  final int crystals;
  final Map<int, int> levelStars; // level ID -> stars (1-3)

  UserProgress({
    this.maxUnlockedLevel = 1,
    this.crystals = 0,
    Map<int, int>? levelStars,
  }) : levelStars = levelStars ?? {};

  UserProgress copyWith({
    int? maxUnlockedLevel,
    int? crystals,
    Map<int, int>? levelStars,
  }) {
    return UserProgress(
      maxUnlockedLevel: maxUnlockedLevel ?? this.maxUnlockedLevel,
      crystals: crystals ?? this.crystals,
      levelStars: levelStars ?? this.levelStars,
    );
  }
}

class ProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() {
    final box = Hive.box('progress');
    final maxUnlockedLevel = box.get('maxUnlockedLevel', defaultValue: 1) as int;
    final crystals = box.get('crystals', defaultValue: 0) as int;
    
    // Convert Map<dynamic, dynamic> to Map<int, int>
    final rawStars = box.get('levelStars', defaultValue: {}) as Map<dynamic, dynamic>;
    final levelStars = rawStars.map((key, value) => MapEntry(key as int, value as int));

    return UserProgress(
      maxUnlockedLevel: maxUnlockedLevel,
      crystals: crystals,
      levelStars: levelStars,
    );
  }

  Future<void> updateLevelProgress(int level, int stars, int earnedCrystals) async {
    final box = Hive.box('progress');
    final newLevelStars = Map<int, int>.from(state.levelStars);
    
    if (!newLevelStars.containsKey(level) || newLevelStars[level]! < stars) {
      newLevelStars[level] = stars;
    }

    final newUnlockedLevel = (level == state.maxUnlockedLevel && stars > 0)
        ? state.maxUnlockedLevel + 1
        : state.maxUnlockedLevel;

    final newCrystals = state.crystals + earnedCrystals;

    state = state.copyWith(
      maxUnlockedLevel: newUnlockedLevel,
      levelStars: newLevelStars,
      crystals: newCrystals,
    );

    await box.put('maxUnlockedLevel', state.maxUnlockedLevel);
    await box.put('levelStars', state.levelStars);
    await box.put('crystals', state.crystals);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(() {
  return ProgressNotifier();
});

