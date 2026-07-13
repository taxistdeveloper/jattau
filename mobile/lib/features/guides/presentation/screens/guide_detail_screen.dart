import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jattau/features/guides/data/guides_data.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

class GuideDetailScreen extends StatelessWidget {
  final String guideId;

  const GuideDetailScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final guide = guideById(guideId);
    if (guide == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.guideNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.copy,
            onPressed: () => _copyGuide(context, guide, l10n),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            guide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < guide.sections.length; i++) ...[
            _SectionCard(section: guide.sections[i]),
            if (i < guide.sections.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Future<void> _copyGuide(BuildContext context, Guide guide, AppLocalizations l10n) async {
    final buffer = StringBuffer()..writeln(guide.title)..writeln();
    for (final section in guide.sections) {
      buffer.writeln(section.title);
      buffer.writeln(section.content);
      if (section.note != null) {
        buffer.writeln('(${section.note})');
      }
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString().trim()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.textCopied)),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final GuideSection section;

  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              section.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
            if (section.note != null) ...[
              const SizedBox(height: 12),
              Text(
                section.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
