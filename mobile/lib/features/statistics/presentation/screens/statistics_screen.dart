import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

final statisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(statisticsRepositoryProvider).getStatistics();
});

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: statsAsync.when(
        data: (data) {
          final stats = data['statistics'] ?? {};
          final streak = data['streak'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(children: [
                  _StatCard(label: l10n.surahsStat, value: '${stats['surahs_studied'] ?? 0}'),
                  _StatCard(label: l10n.ayahsStat, value: '${stats['ayahs_studied'] ?? 0}'),
                  _StatCard(label: l10n.accuracyStat, value: '${stats['avg_accuracy'] ?? 0}%'),
                ]),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
                      const SizedBox(width: 12),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l10n.streakLabel, style: Theme.of(context).textTheme.bodySmall),
                        Text(l10n.daysCount((streak['current_streak'] as num?)?.toInt() ?? 0), style: Theme.of(context).textTheme.headlineSmall),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.weeklyAccuracy, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: LineChart(LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: const [FlSpot(0, 70), FlSpot(1, 75), FlSpot(2, 80), FlSpot(3, 78), FlSpot(4, 85), FlSpot(5, 88), FlSpot(6, 87)],
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                              ),
                            ],
                          )),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(parseApiError(e, l10n))),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      ),
    );
  }
}
