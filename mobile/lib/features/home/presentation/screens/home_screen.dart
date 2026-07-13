import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/utils/locale_helpers.dart';
import 'package:jattau/core/utils/user_progress.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';
import 'package:jattau/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

final mentorProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(statisticsRepositoryProvider).getMentorRecommendations();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mentorAsync = ref.watch(mentorProvider);
    final statsAsync = ref.watch(statisticsProvider);
    final profileAsync = ref.watch(userProfileProvider);

    final data = statsAsync.asData?.value;
    final streak = (data?['streak'] as Map<String, dynamic>?) ?? {};

    final profile = profileAsync.asData?.value;
    final xp = (profile?['experience_points'] as num?)?.toInt() ?? 0;
    final level = (profile?['level'] as num?)?.toInt() ?? 1;
    final xpInLevel = calcXpInLevel(xp);
    final levelProgress = calcLevelProgress(xp);
    final currentStreak = (streak['current_streak'] as num?)?.toInt() ?? 0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.greeting, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(l10n.continueLearning, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
              const SizedBox(height: 8),
              LinearPercentIndicator(
                percent: levelProgress.clamp(0.0, 1.0),
                lineHeight: 8,
                backgroundColor: Colors.grey.shade200,
                progressColor: AppColors.primary,
                barRadius: const Radius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(l10n.levelXp(level, xpInLevel, xpPerLevel), style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(children: [
                    const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
                    const SizedBox(width: 8),
                    Text(l10n.streakDays(currentStreak, dayWord(currentStreak, l10n)), style: Theme.of(context).textTheme.titleMedium),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              mentorAsync.when(
                data: (recs) => recs.isNotEmpty ? Card(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.psychology, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(l10n.aiMentor, style: Theme.of(context).textTheme.titleMedium),
                        ]),
                        const SizedBox(height: 8),
                        Text(recs.first['message'] ?? '', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ) : const SizedBox(),
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),
              Text(l10n.quickActions, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _ActionCard(
                  icon: Icons.menu_book,
                  label: l10n.actionRead,
                  onTap: () => context.go('/surahs'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ActionCard(
                  icon: Icons.psychology_alt,
                  label: l10n.actionMemorize,
                  onTap: () => context.push('/memorization'),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _ActionCard(
                  icon: Icons.auto_stories_outlined,
                  label: l10n.actionGuides,
                  onTap: () => context.push('/guides'),
                )),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
          ]),
        ),
      ),
    );
  }
}
