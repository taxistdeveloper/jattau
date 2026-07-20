import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/features/auth/presentation/screens/login_screen.dart';
import 'package:jattau/features/auth/presentation/screens/pin_screen.dart';
import 'package:jattau/features/auth/presentation/screens/register_screen.dart';
import 'package:jattau/features/auth/presentation/screens/splash_screen.dart';
import 'package:jattau/features/home/presentation/screens/home_screen.dart';
import 'package:jattau/features/surahs/presentation/screens/surahs_screen.dart';
import 'package:jattau/features/surahs/presentation/screens/ayahs_screen.dart';
import 'package:jattau/features/reading/presentation/screens/reading_screen.dart';
import 'package:jattau/features/recitation/presentation/screens/result_screen.dart';
import 'package:jattau/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:jattau/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:jattau/features/profile/presentation/screens/profile_screen.dart';
import 'package:jattau/features/settings/presentation/screens/settings_screen.dart';
import 'package:jattau/features/recitation/presentation/screens/error_history_screen.dart';
import 'package:jattau/features/memorization/presentation/screens/memorization_screen.dart';
import 'package:jattau/features/guides/presentation/screens/guides_screen.dart';
import 'package:jattau/features/guides/presentation/screens/guide_detail_screen.dart';
import 'package:jattau/l10n/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/pin-setup', builder: (_, __) => const PinSetupScreen()),
      GoRoute(path: '/pin', builder: (_, __) => const PinUnlockScreen()),
      ShellRoute(
        builder: (_, __, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/surahs', builder: (_, __) => const SurahsScreen()),
          GoRoute(path: '/statistics', builder: (_, __) => const StatisticsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/surahs/:surahId/ayahs',
        builder: (_, state) => AyahsScreen(surahId: state.pathParameters['surahId']!),
      ),
      GoRoute(
        path: '/reading/:ayahId',
        builder: (_, state) => ReadingScreen(ayahId: state.pathParameters['ayahId']!),
      ),
      GoRoute(
        path: '/result/:recitationId',
        builder: (_, state) => ResultScreen(recitationId: state.pathParameters['recitationId']!),
      ),
      GoRoute(path: '/achievements', builder: (_, __) => const AchievementsScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/errors', builder: (_, __) => const ErrorHistoryScreen()),
      GoRoute(path: '/memorization', builder: (_, __) => const MemorizationScreen()),
      GoRoute(path: '/guides', builder: (_, __) => const GuidesScreen()),
      GoRoute(
        path: '/guides/:guideId',
        builder: (_, state) => GuideDetailScreen(guideId: state.pathParameters['guideId']!),
      ),
    ],
  );
});

class _MainShell extends StatelessWidget {
  final Widget child;
  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateIndex(GoRouterState.of(context).uri.path),
        onDestinationSelected: (i) {
          const routes = ['/home', '/surahs', '/statistics', '/profile'];
          context.go(routes[i]);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: l10n.navHome),
          NavigationDestination(icon: const Icon(Icons.menu_book_outlined), selectedIcon: const Icon(Icons.menu_book), label: l10n.navSurahs),
          NavigationDestination(icon: const Icon(Icons.bar_chart_outlined), selectedIcon: const Icon(Icons.bar_chart), label: l10n.navProgress),
          NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: l10n.navProfile),
        ],
      ),
    );
  }

  int _calculateIndex(String path) {
    if (path.startsWith('/surahs')) return 1;
    if (path.startsWith('/statistics')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }
}
