import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

class PinUnlockScreen extends ConsumerStatefulWidget {
  const PinUnlockScreen({super.key});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  String _pin = '';
  String? _error;
  bool _busy = false;

  void _onDigit(String digit) {
    if (_busy || _pin.length >= 4) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = null;
      _pin += digit;
    });
    if (_pin.length == 4) {
      _verify();
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

  Future<void> _verify() async {
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

  Future<void> _usePassword() async {
    await ref.read(authStateProvider.notifier).logout();
    if (!mounted) return;
    context.go('/login');
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
              Icon(Icons.lock_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                l10n.pinEnter,
                style: Theme.of(context).textTheme.headlineSmall,
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
              const SizedBox(height: 8),
              TextButton(
                onPressed: _usePassword,
                child: Text(l10n.pinUsePassword),
              ),
              const SizedBox(height: 16),
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
