import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> init({double rate = 0.45, double pitch = 1.0}) async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    // Prime the TTS engine so the first real speak has no cold-start delay
    await _tts.speak('');
    await _tts.stop();
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    unawaited(_tts.stop());
  }
}
