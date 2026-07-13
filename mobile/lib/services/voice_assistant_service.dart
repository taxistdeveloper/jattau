import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceAssistantService {
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  Function(String)? onCommand;

  static const commands = {
    'начать чтение': 'start_reading',
    'следующий аят': 'next_ayah',
    'повторить': 'repeat',
    'проверить чтение': 'check_reading',
    'продолжить урок': 'continue_lesson',
  };

  Future<bool> initialize() async {
    return _speech.initialize();
  }

  Future<void> startListening({Function(String)? onCommand}) async {
    this.onCommand = onCommand;
    if (_isListening) return;

    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();
        for (final entry in commands.entries) {
          if (text.contains(entry.key)) {
            onCommand?.call(entry.value);
            break;
          }
        }
      },
      localeId: 'ru_RU',
      listenOptions: SpeechListenOptions(listenMode: ListenMode.confirmation),
    );
  }

  Future<void> stopListening() async {
    _isListening = false;
    await _speech.stop();
  }

  void dispose() {
    _speech.cancel();
  }
}
