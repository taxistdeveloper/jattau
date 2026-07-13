import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jattau/core/providers/locale_provider.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<Map<String, String>> _deck = [
  {
    'id': '1:1',
    'arabic': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'translation_ru': 'Во имя Аллаха, Милостивого, Милосердного',
    'translation_kk': 'Рахман, Рахим – қамқор әрі мейірімді Алланың атымен.',
  },
  {
    'id': '1:2',
    'arabic': 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    'translation_ru': 'Хвала Аллаху, Господу миров',
    'translation_kk': 'Мактоу Эллие ғаламдардың Раббысына!',
  },
  {
    'id': '1:3',
    'arabic': 'الرَّحْمَٰنِ الرَّحِيمِ',
    'translation_ru': 'Милостивому, Милосердному',
    'translation_kk': 'Рахман, Рахим!',
  },
  {
    'id': '1:4',
    'arabic': 'مَالِكِ يَوْمِ الدِّينِ',
    'translation_ru': 'Властелину Дня воздаяния',
    'translation_kk': 'Қиямет күнінің әміршісі!',
  },
  {
    'id': '1:5',
    'arabic': 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
    'translation_ru': 'Тебе одному мы поклоняемся и Тебя одного молим о помощи',
    'translation_kk': '(Тек) Саған ғана табынамыз және (Тек) Сенен ғана көмек сұраймыз.',
  },
  {
    'id': '1:6',
    'arabic': 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
    'translation_ru': 'Веди нас прямым путём',
    'translation_kk': 'Бізді түзу жолға бағытта!',
  },
  {
    'id': '1:7',
    'arabic':
        'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    'translation_ru':
        'путём тех, кого Ты облагодетельствовал, не тех, на кого пал гнев, и не заблудших',
    'translation_kk':
        'Өз ыңғайына дәл келдіргендердің жолымен, оған ашу күйіп-өнгендердің және адасқандардың емес.',
  },
];

const String _prefsKey = 'memorization_progress_v1';

enum ReviewGrade { again, hard, good, easy }

class _CardProgress {
  int repetitions;
  double ease;
  int intervalDays;
  int dueAtMs;

  _CardProgress({
    this.repetitions = 0,
    this.ease = 2.5,
    this.intervalDays = 0,
    this.dueAtMs = 0,
  });

  bool get isNew => repetitions == 0 && dueAtMs == 0;
  bool get isMature => intervalDays >= 21;

  Map<String, dynamic> toJson() => {
        'repetitions': repetitions,
        'ease': ease,
        'intervalDays': intervalDays,
        'dueAtMs': dueAtMs,
      };

  factory _CardProgress.fromJson(Map<String, dynamic> json) => _CardProgress(
        repetitions: json['repetitions'] as int? ?? 0,
        ease: (json['ease'] as num?)?.toDouble() ?? 2.5,
        intervalDays: json['intervalDays'] as int? ?? 0,
        dueAtMs: json['dueAtMs'] as int? ?? 0,
      );

  void apply(ReviewGrade grade) {
    final now = DateTime.now();
    switch (grade) {
      case ReviewGrade.again:
        repetitions = 0;
        ease = (ease - 0.2).clamp(1.3, 3.0);
        intervalDays = 0;
        dueAtMs = now.add(const Duration(minutes: 10)).millisecondsSinceEpoch;
        return;
      case ReviewGrade.hard:
        ease = (ease - 0.15).clamp(1.3, 3.0);
        intervalDays = intervalDays == 0 ? 1 : (intervalDays * 1.2).ceil();
        break;
      case ReviewGrade.good:
        if (repetitions == 0) {
          intervalDays = 1;
        } else if (repetitions == 1) {
          intervalDays = 3;
        } else {
          intervalDays = (intervalDays * ease).ceil();
        }
        break;
      case ReviewGrade.easy:
        ease = (ease + 0.15).clamp(1.3, 3.0);
        intervalDays = intervalDays == 0 ? 2 : (intervalDays * ease * 1.3).ceil();
        break;
    }
    repetitions += 1;
    dueAtMs = now.add(Duration(days: intervalDays)).millisecondsSinceEpoch;
  }
}

class MemorizationScreen extends ConsumerStatefulWidget {
  const MemorizationScreen({super.key});

  @override
  ConsumerState<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends ConsumerState<MemorizationScreen> {
  final Map<String, _CardProgress> _progress = {};
  List<String> _queue = [];
  int _queueIndex = 0;
  bool _revealed = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded.forEach((key, value) {
        _progress[key] = _CardProgress.fromJson(value as Map<String, dynamic>);
      });
    }
    for (final card in _deck) {
      _progress.putIfAbsent(card['id']!, () => _CardProgress());
    }
    _buildQueue();
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = _progress.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  void _buildQueue() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _queue = _deck
        .map((c) => c['id']!)
        .where((id) {
          final p = _progress[id]!;
          return p.isNew || p.dueAtMs <= now;
        })
        .toList();
    _queueIndex = 0;
    _revealed = false;
  }

  Map<String, String> get _currentCard {
    final id = _queue[_queueIndex];
    return _deck.firstWhere((c) => c['id'] == id);
  }

  String _cardTranslation(Map<String, String> card, bool isKk) {
    return isKk ? (card['translation_kk'] ?? card['translation_ru']!) : (card['translation_ru']!);
  }

  Future<void> _grade(ReviewGrade grade) async {
    final id = _queue[_queueIndex];
    _progress[id]!.apply(grade);
    await _save();
    setState(() {
      _revealed = false;
      if (_queueIndex < _queue.length - 1) {
        _queueIndex += 1;
      } else {
        _buildQueue();
      }
    });
  }

  int get _newCount => _progress.values.where((p) => p.isNew).length;

  int get _dueCount {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _progress.values
        .where((p) => !p.isNew && p.dueAtMs <= now)
        .length;
  }

  int get _masteredPercent {
    if (_progress.isEmpty) return 0;
    final mature = _progress.values.where((p) => p.isMature).length;
    return ((mature / _progress.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKk = isKazakhLocale(ref.watch(localeProvider) ?? Localizations.localeOf(context));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.memorizationTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _Info(l10n.newCards, '$_newCount'),
                          _Info(l10n.reviewCards, '$_dueCount'),
                          _Info(l10n.memorized, '$_masteredPercent%'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _queue.isEmpty
                        ? _AllDoneView(l10n: l10n)
                        : _ReviewView(
                            card: _currentCard,
                            translation: _cardTranslation(_currentCard, isKk),
                            revealed: _revealed,
                            showTranslationLabel: l10n.showTranslation,
                            onReveal: () => setState(() => _revealed = true),
                          ),
                  ),
                  if (_queue.isNotEmpty && _revealed)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ReviewButton(
                          label: l10n.again,
                          color: Colors.red,
                          icon: Icons.close,
                          onTap: () => _grade(ReviewGrade.again),
                        ),
                        _ReviewButton(
                          label: l10n.hard,
                          color: Colors.orange,
                          icon: Icons.help,
                          onTap: () => _grade(ReviewGrade.hard),
                        ),
                        _ReviewButton(
                          label: l10n.good,
                          color: AppColors.primary,
                          icon: Icons.check,
                          onTap: () => _grade(ReviewGrade.good),
                        ),
                        _ReviewButton(
                          label: l10n.easy,
                          color: AppColors.success,
                          icon: Icons.star,
                          onTap: () => _grade(ReviewGrade.easy),
                        ),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}

class _ReviewView extends StatelessWidget {
  final Map<String, String> card;
  final String translation;
  final bool revealed;
  final String showTranslationLabel;
  final VoidCallback onReveal;

  const _ReviewView({
    required this.card,
    required this.translation,
    required this.revealed,
    required this.showTranslationLabel,
    required this.onReveal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card['arabic']!,
            style: AppTheme.arabicText(fontSize: 36),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          if (revealed)
            Text(
              translation,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )
          else
            FilledButton.tonal(
              onPressed: onReveal,
              child: Text(showTranslationLabel),
            ),
        ],
      ),
    );
  }
}

class _AllDoneView extends StatelessWidget {
  final AppLocalizations l10n;
  const _AllDoneView({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          Text(
            l10n.allDoneToday,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.comeBackLater,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String value;
  const _Info(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.primary)),
      Text(label, style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _ReviewButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ReviewButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Column(children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}
