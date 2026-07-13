import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/utils/json_parse.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

final recitationResultProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.watch(recitationRepositoryProvider).getResult(id);
});

class ResultScreen extends ConsumerWidget {
  final String recitationId;
  const ResultScreen({super.key, required this.recitationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final resultAsync = ref.watch(recitationResultProvider(recitationId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: resultAsync.when(
        data: (data) {
          final result = data['result'];
          if (result == null) return Center(child: Text(l10n.processing));
          final accuracy = parseDouble(result['accuracy_percent']);
          final passed = parseBool(result['is_passed']);
          final skipped = parseJsonList(result['words_skipped']);
          final mispronounced = parseJsonList(result['words_mispronounced']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 80,
                  lineWidth: 12,
                  percent: accuracy / 100,
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${accuracy.toInt()}%', style: Theme.of(context).textTheme.headlineLarge),
                      Icon(passed ? Icons.check_circle : Icons.warning, color: passed ? AppColors.success : Colors.orange),
                    ],
                  ),
                  progressColor: passed ? AppColors.success : Colors.orange,
                ),
                const SizedBox(height: 24),
                if (!passed) ...[
                  Text(l10n.errorsCount(skipped.length + mispronounced.length), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  ...mispronounced.map((e) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.error, color: Colors.red),
                      title: Text(l10n.expected(e['expected'] ?? ''), style: AppTheme.arabicText(fontSize: 18), textDirection: TextDirection.rtl),
                      subtitle: Text(l10n.actual(e['actual'] ?? '')),
                    ),
                  )),
                  ...skipped.map((e) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.remove_circle, color: Colors.orange),
                      title: Text(l10n.skipped(e['word'] ?? ''), style: AppTheme.arabicText(fontSize: 18), textDirection: TextDirection.rtl),
                    ),
                  )),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ] else ...[
                  Text(l10n.excellentXp, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.success)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/surahs'),
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(l10n.nextAyah),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorPrefix(e.toString()))),
      ),
    );
  }
}
