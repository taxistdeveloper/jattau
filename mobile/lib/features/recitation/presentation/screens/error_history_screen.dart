import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

final errorsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(recitationRepositoryProvider).getErrors();
});

class ErrorHistoryScreen extends ConsumerWidget {
  const ErrorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final errorsAsync = ref.watch(errorsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.errorHistoryTitle)),
      body: errorsAsync.when(
        data: (errors) => errors.isEmpty
            ? Center(child: Text(l10n.noErrorsYet))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: errors.length,
                itemBuilder: (_, i) {
                  final e = errors[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        e['error_type'] == 'skipped' ? Icons.remove_circle : Icons.error,
                        color: e['error_type'] == 'skipped' ? Colors.orange : Colors.red,
                      ),
                      title: Text(e['word_expected'] ?? '', style: AppTheme.arabicText(fontSize: 18), textDirection: TextDirection.rtl),
                      subtitle: Text(l10n.ayahNumber(e['surah_name'] ?? '', (e['ayah_number'] as num?)?.toInt() ?? 0)),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorPrefix(e.toString()))),
      ),
    );
  }
}
