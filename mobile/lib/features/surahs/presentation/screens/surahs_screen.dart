import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/providers/locale_provider.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

final surahsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(quranRepositoryProvider).getSurahs();
});

class SurahsScreen extends ConsumerWidget {
  const SurahsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isKk = isKazakhLocale(ref.watch(localeProvider) ?? Localizations.localeOf(context));
    final surahsAsync = ref.watch(surahsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.surahsTitle)),
      body: surahsAsync.when(
        data: (surahs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surahs.length,
          itemBuilder: (_, i) {
            final s = surahs[i];
            final translation = isKk
                ? (s['name_translation_kk'] ?? s['name_translation'] ?? '')
                : (s['name_translation'] ?? s['name_translation_kk'] ?? '');
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text('${s['number']}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
                title: Text(s['name_arabic'] ?? '', style: AppTheme.arabicText(fontSize: 20), textDirection: TextDirection.rtl),
                subtitle: Text(
                  '${s['name_transliteration']} • $translation • ${l10n.ayahCount(s['ayah_count'] as int? ?? 0)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/surahs/${s['id']}/ayahs'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(parseApiError(e, l10n))),
      ),
    );
  }
}
