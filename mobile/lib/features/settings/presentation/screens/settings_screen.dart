import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/core/providers/locale_provider.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final currentLang = locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.languageSection, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'ru', label: Text(l10n.languageRussian)),
              ButtonSegment(value: 'kk', label: Text(l10n.languageKazakh)),
            ],
            selected: {currentLang == 'kk' ? 'kk' : 'ru'},
            onSelectionChanged: (s) {
              ref.read(localeProvider.notifier).setLocale(Locale(s.first));
            },
          ),
          const Divider(height: 32),
          Text(l10n.displaySection, style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(title: Text(l10n.transliteration), value: true, onChanged: (_) {}),
          SwitchListTile(title: Text(l10n.translation), value: true, onChanged: (_) {}),
          ListTile(title: Text(l10n.fontSize), trailing: const Text('28'), onTap: () {}),
          const Divider(),
          Text(l10n.readingSection, style: Theme.of(context).textTheme.titleMedium),
          ListTile(title: Text(l10n.accuracyThreshold), trailing: const Text('85%')),
          SwitchListTile(title: Text(l10n.voiceCommands), value: true, onChanged: (_) {}),
          const Divider(),
          Text(l10n.themeSection, style: Theme.of(context).textTheme.titleMedium),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight)),
              ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark)),
              ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeAuto)),
            ],
            selected: {ref.watch(themeModeProvider)},
            onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).state = s.first,
          ),
        ],
      ),
    );
  }
}
