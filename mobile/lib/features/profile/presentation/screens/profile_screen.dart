import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';
import 'package:jattau/features/auth/presentation/providers/auth_provider.dart';
import 'package:jattau/l10n/app_localizations.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: profileAsync.when(
              data: (user) => Column(children: [
                const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                const SizedBox(height: 12),
                Text(
                  user['full_name'] as String? ?? l10n.defaultUser,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(l10n.levelBadge((user['level'] as num?)?.toInt() ?? 1)),
              ]),
              loading: () => const Column(children: [
                CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                SizedBox(height: 12),
                CircularProgressIndicator(),
              ]),
              error: (_, __) => Column(children: [
                const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                const SizedBox(height: 12),
                Text(l10n.defaultUser, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(l10n.levelBadge(1)),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          _MenuTile(icon: Icons.settings, title: l10n.settings, onTap: () => context.push('/settings')),
          _MenuTile(icon: Icons.history, title: l10n.errorHistory, onTap: () => context.push('/errors')),
          _MenuTile(icon: Icons.emoji_events, title: l10n.achievements, onTap: () => context.push('/achievements')),
          _MenuTile(icon: Icons.menu_book_outlined, title: l10n.guides, onTap: () => context.push('/guides')),
          const Divider(),
          _MenuTile(
            icon: Icons.logout,
            title: l10n.logout,
            color: Colors.red,
            onTap: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.title, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(leading: Icon(icon, color: color), title: Text(title, style: TextStyle(color: color)), onTap: onTap),
    );
  }
}
