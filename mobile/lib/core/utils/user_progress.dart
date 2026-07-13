/// Сколько XP нужно на один уровень.
const int xpPerLevel = 500;

/// XP вычисляется из реального прогресса пользователя.
int calcXp(Map<String, dynamic> stats) {
  final ayahs = (stats['ayahs_studied'] as num?)?.toInt() ?? 0;
  final memorized = (stats['ayahs_memorized'] as num?)?.toInt() ?? 0;
  final recitations = (stats['total_recitations'] as num?)?.toInt() ?? 0;
  return ayahs * 20 + memorized * 50 + recitations * 10;
}

int calcLevel(int xp) => xp ~/ xpPerLevel + 1;

int calcXpInLevel(int xp) => xp % xpPerLevel;

double calcLevelProgress(int xp) => calcXpInLevel(xp) / xpPerLevel;
