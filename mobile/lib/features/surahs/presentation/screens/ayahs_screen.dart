import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

final ayahsProvider = FutureProvider.family<List<dynamic>, String>((ref, surahId) async {
  return ref.watch(quranRepositoryProvider).getAyahs(surahId);
});

class AyahsScreen extends ConsumerWidget {
  final String surahId;
  const AyahsScreen({super.key, required this.surahId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ayahsAsync = ref.watch(ayahsProvider(surahId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ayahsTitle)),
      body: ayahsAsync.when(
        data: (ayahs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ayahs.length,
          itemBuilder: (_, i) {
            final a = ayahs[i];
            final isLocked = i > 2;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${a['number']}')),
                title: Text(
                  a['text_uthmani'] ?? '',
                  style: AppTheme.arabicText(fontSize: 18),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((a['text_transliteration'] ?? '').isNotEmpty)
                      Text(a['text_transliteration'] ?? '', style: Theme.of(context).textTheme.bodySmall),
                    if ((a['text_transliteration_kk'] ?? '').isNotEmpty)
                      Text(a['text_transliteration_kk'] ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey.shade600)),
                  ],
                ),
                trailing: isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : const Icon(Icons.mic, color: Colors.green),
                enabled: !isLocked,
                onTap: isLocked ? null : () => context.push('/reading/${a['id']}'),
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
