import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/features/auth/data/auth_repository.dart';
import 'package:jattau/features/auth/data/pin_repository.dart';
import 'package:jattau/features/auth/presentation/providers/auth_provider.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _pin = '';
  String? _firstPin;
  String? _error;

  bool get _isConfirm => _firstPin != null;

  void _onDigit(String digit) {
    if (_pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _onComplete();
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _onComplete() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_isConfirm) {
      setState(() {
        _firstPin = _pin;
        _pin = '';
      });
      return;
    }

    if (_pin != _firstPin) {
      setState(() {
        _error = l10n.pinMismatch;
        _firstPin = null;
        _pin = '';
      });
      return;
    }

    await ref.read(pinRepositoryProvider).setPin(_pin);
    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.lock_outline, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                _isConfirm ? l10n.pinConfirm : l10n.pinCreate,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pinCreateHint,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _PinDots(filled: _pin.length, error: _error != null),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              const Spacer(),
              _PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

enum _UnlockMethod { pin, password }

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  _UnlockMethod _method = _UnlockMethod.pin;
  String _pin = '';
  String? _error;
  bool _busy = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  Future<void> _loadEmail() async {
    final email = await ref.read(authRepositoryProvider).savedEmail();
    if (!mounted || email == null) return;
    _emailController.text = email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchMethod(_UnlockMethod method) {
    setState(() {
      _method = method;
      _error = null;
      _pin = '';
      _busy = false;
    });
  }

  void _onDigit(String digit) {
    if (_busy || _pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _onBackspace() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _busy = true);
    final ok = await ref.read(pinRepositoryProvider).verifyPin(_pin);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _error = AppLocalizations.of(context)!.pinWrong;
      _pin = '';
      _busy = false;
    });
  }

  Future<void> _loginWithPassword() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _error = null;
    });
    await ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    final state = ref.read(authStateProvider);
    if (state.hasError) {
      setState(() {
        _busy = false;
        _error = parseApiError(state.error!, l10n);
      });
      return;
    }
    if (state.value == true) {
      context.go('/home');
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              SegmentedButton<_UnlockMethod>(
                segments: [
                  ButtonSegment(
                    value: _UnlockMethod.pin,
                    label: Text(l10n.loginMethodPin),
                    icon: const Icon(Icons.pin_outlined),
                  ),
                  ButtonSegment(
                    value: _UnlockMethod.password,
                    label: Text(l10n.loginMethodPassword),
                    icon: const Icon(Icons.password_outlined),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: (s) => _switchMethod(s.first),
              ),
              const Spacer(),
              Icon(
                _method == _UnlockMethod.pin ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _method == _UnlockMethod.pin ? l10n.pinEnter : l10n.loginWithPassword,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_method == _UnlockMethod.pin) ...[
                _PinDots(filled: _pin.length, error: _error != null),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const Spacer(),
                _PinPad(onDigit: _onDigit, onBackspace: _onBackspace),
                const SizedBox(height: 24),
              ] else ...[
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_busy,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.password),
                  obscureText: true,
                  enabled: !_busy,
                  onSubmitted: (_) => _busy ? null : _loginWithPassword(),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _loginWithPassword,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.login),
                ),
                const Spacer(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PinDots extends StatelessWidget {
  final int filled;
  final bool error;

  const _PinDots({required this.filled, this.error = false});

  @override
  Widget build(BuildContext context) {
    final color = error ? Theme.of(context).colorScheme.error : AppColors.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final isFilled = i < filled;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
        );
      }),
    );
  }
}

class _PinPad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const _PinPad({required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) {
              if (key.isEmpty) {
                return const SizedBox(width: 72, height: 72);
              }
              final isBackspace = key == '⌫';
              return SizedBox(
                width: 72,
                height: 72,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => isBackspace ? onBackspace() : onDigit(key),
                    child: Center(
                      child: isBackspace
                          ? const Icon(Icons.backspace_outlined, size: 28)
                          : Text(key, style: Theme.of(context).textTheme.headlineMedium),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
