import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';
import 'package:jattau/features/auth/data/pin_repository.dart';
import 'package:jattau/theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final repo = ref.read(authRepositoryProvider);
    final loggedIn = await repo.isLoggedIn();
    if (!mounted) return;
    if (!loggedIn) {
      context.go('/login');
      return;
    }
    final hasPin = await ref.read(pinRepositoryProvider).hasPin();
    if (!mounted) return;
    context.go(hasPin ? '/pin' : '/pin-setup');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_rounded, size: 80, color: Colors.white.withValues(alpha: 0.9)),
              const SizedBox(height: 16),
              Text('Jattau', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text('جَتَّوْ', style: AppTheme.arabicText(fontSize: 24, color: Colors.white70)),
              const SizedBox(height: 32),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
