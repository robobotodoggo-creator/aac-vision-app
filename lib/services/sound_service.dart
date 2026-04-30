import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

/// Lightweight sound effects service for tile tap feedback.
/// Generates a short click WAV programmatically — no asset files needed.
class SoundService {
  AudioPlayer? _player;
  late Uint8List _clickSound;

  Future<void> init() async {
    _clickSound = _generateClickWav();
    _player = AudioPlayer();
  }

  Future<void> playTap() async {
    final player = _player;
    if (player == null) return;
    try {
      await player.stop();
      await player.play(BytesSource(_clickSound));
    } catch (_) {
      // Sound effects are non-critical — swallow errors silently
    }
  }

  void dispose() {
    _player?.dispose();
    _player = null;
  }

  /// Generates a 50ms click/pop WAV: 800 Hz sine burst with exponential decay.
  /// 22050 Hz, 16-bit mono PCM. ~2 KB total.
  Uint8List _generateClickWav() {
    const sampleRate = 22050;
    const durationMs = 50;
    const frequency = 800.0;
    final numSamples = (sampleRate * durationMs / 1000).round();
    final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
    final fileSize = 44 + dataSize;

    final bytes = ByteData(fileSize);

    // RIFF header
    _writeString(bytes, 0, 'RIFF');
    bytes.setUint32(4, fileSize - 8, Endian.little);
    _writeString(bytes, 8, 'WAVE');

    // fmt chunk
    _writeString(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little); // chunk size
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, 1, Endian.little); // mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little); // byte rate
    bytes.setUint16(32, 2, Endian.little); // block align
    bytes.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    _writeString(bytes, 36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    // Sine wave with exponential decay
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = exp(-t * 60);
      final sample =
          (sin(2 * pi * frequency * t) * envelope * 16000).round().clamp(-32768, 32767);
      bytes.setInt16(44 + i * 2, sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  void _writeString(ByteData bytes, int offset, String str) {
    for (int i = 0; i < str.length; i++) {
      bytes.setUint8(offset + i, str.codeUnitAt(i));
    }
  }
}
