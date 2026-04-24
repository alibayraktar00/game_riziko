import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;

  Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize(
        onError: (error) {},
        onStatus: (status) {},
      );
    }
    return _isInitialized;
  }

  Future<void> startListening({required Function(String) onResult}) async {
    if (!_isInitialized) {
      final init = await initialize();
      if (!init) return;
    }
    
    if (!_speech.isListening) {
      await _speech.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
        },
      );
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  bool get isListening => _speech.isListening;
}

final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});
