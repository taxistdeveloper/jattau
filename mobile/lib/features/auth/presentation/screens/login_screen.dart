import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/features/auth/data/pin_repository.dart';
import 'package:jattau/features/auth/presentation/providers/auth_provider.dart';
import 'package:jattau/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    await ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    final state = ref.read(authStateProvider);
    if (state.hasError) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(parseApiError(state.error!, l10n))),
      );
      return;
    }
    if (state.value == true) {
      final hasPin = await ref.read(pinRepositoryProvider).hasPin();
      if (!mounted) return;
      context.go(hasPin ? '/pin' : '/pin-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Text(l10n.welcome, style: Theme.of(context).textTheme.headlineMedium),
              Text(l10n.inJattau, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              )),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: l10n.password),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.testCredentials,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.login),
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/register'),
                  child: Text(l10n.noAccountRegister),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
