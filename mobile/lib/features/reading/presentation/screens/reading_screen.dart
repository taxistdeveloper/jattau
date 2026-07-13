import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jattau/core/providers/locale_provider.dart';
import 'package:jattau/core/utils/api_error.dart';
import 'package:jattau/core/utils/arabic_matching.dart';
import 'package:jattau/core/utils/reference_audio.dart';
import 'package:jattau/features/surahs/data/quran_repository.dart';
import 'package:jattau/l10n/app_localizations.dart';
import 'package:jattau/theme/app_theme.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:speech_to_text/speech_to_text.dart';

final ayahProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, id) async {
  return ref.watch(quranRepositoryProvider).getAyah(id);
});

class ReadingScreen extends ConsumerStatefulWidget {
  final String ayahId;
  const ReadingScreen({super.key, required this.ayahId});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  final _speech = SpeechToText();

  bool _isRecording = false;
  int _seconds = 0;
  Timer? _timer;

  bool _speechReady = false;
  bool _liveActive = false;
  bool _isPlayingReference = false;
  List<String> _expectedWords = const [];
  List<WordStatus> _statuses = const [];
  String _spokenText = '';
  String? _arabicLocaleId;

  @override
  void initState() {
    super.initState();
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlayingReference = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _player.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      _timer?.cancel();
      setState(() { _isRecording = false; });
      if (path != null) _submitRecitation(path);
    } else {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.wav), path: path);
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _seconds++));
      setState(() { _isRecording = true; _seconds = 0; });
    }
  }

  Future<void> _submitRecitation(String path) async {
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final result = await ref.read(recitationRepositoryProvider).submitRecitation(
        widget.ayahId, path, _seconds.toDouble(),
      );
      if (mounted) {
        Navigator.pop(context);
        context.push('/result/${result['recitation']['id']}');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(parseApiError(e, l10n))));
      }
    }
  }

  Future<void> _playReference(Map<String, dynamic> ayah) async {
    final l10n = AppLocalizations.of(context)!;
    final url = ReferenceAudio.urlForAyah(ayah);
    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.referenceAudioFailed)),
        );
      }
      return;
    }

    setState(() => _isPlayingReference = true);
    try {
      await _player.stop();
      await _player.play(UrlSource(url, mimeType: 'audio/mpeg'));
    } catch (_) {
      if (mounted) {
        setState(() => _isPlayingReference = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.referenceAudioFailed)),
        );
      }
    }
  }

  Future<void> _toggleLive(String ayahText) async {
    final l10n = AppLocalizations.of(context)!;
    if (_liveActive) {
      await _stopLive();
      return;
    }

    if (!_speechReady) {
      _speechReady = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.speechUnavailable(e.errorMsg))),
            );
          }
        },
      );
    }

    if (!_speechReady) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechNotOnDevice)),
        );
      }
      return;
    }

    _arabicLocaleId = await _resolveArabicLocale();
    if (_arabicLocaleId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.arabicLocaleMissing),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return;
    }

    _expectedWords = tokenizeArabic(ayahText);
    setState(() {
      _liveActive = true;
      _spokenText = '';
      _statuses = List<WordStatus>.filled(_expectedWords.length, WordStatus.pending);
    });
    await _startListening();
  }

  Future<String?> _resolveArabicLocale() async {
    final locales = await _speech.locales();
    const preferred = ['ar_SA', 'ar-SA', 'ar_AE', 'ar-AE', 'ar_KW', 'ar'];
    for (final id in preferred) {
      if (locales.any((l) => l.localeId == id)) return id;
    }
    final arabic = locales.where((l) => l.localeId.startsWith('ar'));
    return arabic.isNotEmpty ? arabic.first.localeId : null;
  }

  Future<void> _startListening() async {
    if (_arabicLocaleId == null) return;
    await _speech.listen(
      onResult: (result) {
        final spoken = tokenizeArabic(result.recognizedWords);
        setState(() {
          _spokenText = result.recognizedWords;
          _statuses = analyzeLiveRecitation(_expectedWords, spoken);
        });
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        listenMode: ListenMode.dictation,
        localeId: _arabicLocaleId,
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(seconds: 30),
      ),
    );
  }

  void _onSpeechStatus(String status) {
    if ((status == 'done' || status == 'notListening') && _liveActive) {
      _startListening();
    }
  }

  Future<void> _stopLive() async {
    await _speech.stop();
    if (mounted) setState(() => _liveActive = false);
  }

  Widget _buildLiveAyah(AppLocalizations l10n) {
    final correct = _statuses.where((s) => s == WordStatus.correct).length;
    final total = _expectedWords.length;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          textDirection: TextDirection.rtl,
          spacing: 6,
          runSpacing: 4,
          children: [
            for (var i = 0; i < _expectedWords.length; i++)
              Text(
                _expectedWords[i],
                textDirection: TextDirection.rtl,
                style: AppTheme.arabicText(fontSize: 30).copyWith(
                  color: switch (_statuses[i]) {
                    WordStatus.correct => AppColors.success,
                    WordStatus.wrong => AppColors.error,
                    WordStatus.pending => Colors.grey.shade400,
                  },
                  fontWeight: _statuses[i] == WordStatus.pending
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.correctCount(correct, total),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Card(
          color: AppColors.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hearing, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      l10n.youSaid,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _spokenText.isEmpty ? l10n.listening : _spokenText,
                  textDirection: _spokenText.isEmpty ? TextDirection.ltr : TextDirection.rtl,
                  style: _spokenText.isEmpty
                      ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        )
                      : AppTheme.arabicText(fontSize: 22),
                  textAlign: _spokenText.isEmpty ? TextAlign.center : TextAlign.right,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isKk = isKazakhLocale(ref.watch(localeProvider) ?? Localizations.localeOf(context));
    final ayahAsync = ref.watch(ayahProvider(widget.ayahId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.readingTitle)),
      body: ayahAsync.when(
        data: (ayah) {
          final ayahText = ayah['text_uthmani'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  if (_liveActive)
                    _buildLiveAyah(l10n)
                  else
                    Text(ayahText, style: AppTheme.arabicText(fontSize: 32), textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                  const SizedBox(height: 16),
                  if (!_liveActive) ...[
                    if ((ayah['text_transliteration'] ?? '').isNotEmpty)
                      Text(ayah['text_transliteration'] ?? '', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                    if ((ayah['text_transliteration_kk'] ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(ayah['text_transliteration_kk'] ?? '', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontStyle: FontStyle.italic), textAlign: TextAlign.center),
                    ],
                    const SizedBox(height: 8),
                    if (isKk) ...[
                      if ((ayah['text_translation_kk'] ?? '').isNotEmpty)
                        Text(ayah['text_translation_kk'] ?? '', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                    ] else ...[
                      if ((ayah['text_translation_ru'] ?? '').isNotEmpty)
                        Text(ayah['text_translation_ru'] ?? '', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                      if ((ayah['text_translation_kk'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(ayah['text_translation_kk'] ?? '', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
                      ],
                    ],
                  ],
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _isRecording ? null : () => _toggleLive(ayahText),
                    child: Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _liveActive ? AppColors.error : AppColors.primary,
                        boxShadow: [BoxShadow(color: (_liveActive ? AppColors.error : AppColors.primary).withValues(alpha: 0.3), blurRadius: 20, spreadRadius: 5)],
                      ),
                      child: Icon(_liveActive ? Icons.stop : Icons.record_voice_over, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _liveActive ? l10n.liveChecking : l10n.readWithHighlight,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _liveActive ? null : _toggleRecording,
                        icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                        label: Text(_isRecording ? l10n.stopSeconds(_seconds) : l10n.checkOnServer),
                      ),
                      TextButton.icon(
                        onPressed: _isPlayingReference ? null : () => _playReference(ayah),
                        icon: Icon(_isPlayingReference ? Icons.volume_up : Icons.play_arrow),
                        label: Text(_isPlayingReference ? l10n.referencePlaying : l10n.reference),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(parseApiError(e, l10n))),
      ),
    );
  }
}
