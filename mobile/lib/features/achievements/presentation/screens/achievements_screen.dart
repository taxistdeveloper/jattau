import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/core/utils/user_progress.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  List<(String, String Function(AppLocalizations), bool)> _achievements(AppLocalizations l10n) => [
    ('🏆', (l) => l.achievementFirstAyah, true),
    ('🔥', (l) => l.achievementStreak7, true),
    ('📖', (l) => l.achievement10Ayahs, true),
    ('⭐', (l) => l.achievementSurah1, false),
    ('🧠', (l) => l.achievement5Memorized, false),
    ('🎯', (l) => l.achievement90Accuracy, false),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);

    final profile = profileAsync.asData?.value;
    final xp = (profile?['experience_points'] as num?)?.toInt() ?? 0;
    final level = (profile?['level'] as num?)?.toInt() ?? 1;
    final xpInLevel = calcXpInLevel(xp);
    final achievements = _achievements(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.achievementsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(l10n.levelXpShort(level, xpInLevel), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: calcLevelProgress(xp).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: achievements.length,
              itemBuilder: (_, i) {
                final (icon, titleFn, earned) = achievements[i];
                return Card(
                  color: earned ? AppColors.primary.withValues(alpha: 0.08) : Colors.grey.shade100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(icon, style: TextStyle(fontSize: 32, color: earned ? null : Colors.grey)),
                      const SizedBox(height: 4),
                      Text(titleFn(l10n), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                      if (earned) const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
