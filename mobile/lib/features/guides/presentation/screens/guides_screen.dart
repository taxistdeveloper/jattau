import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/features/guides/data/guides_data.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidesTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final guide = guides[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(Icons.menu_book, color: AppColors.primary),
              ),
              title: Text(guide.title, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(guide.subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/guides/${guide.id}'),
            ),
          );
        },
      ),
    );
  }
}
