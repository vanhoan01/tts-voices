import 'package:flutter_test/flutter_test.dart';
import 'package:tts_voices/tts_voices.dart';

void main() {
  group('VoiceConfig', () {
    test('Default values', () {
      const config = VoiceConfig();
      expect(config.gender, 'female');
      expect(config.age, 'adult');
      expect(config.pitch, 1.0);
      expect(config.rate, 0.5);
      expect(config.volume, 1.0);
    });

    test('Custom values', () {
      const config = VoiceConfig(
        gender: 'male',
        age: 'child',
        pitch: 1.5,
        rate: 0.8,
        volume: 0.7,
      );
      expect(config.gender, 'male');
      expect(config.age, 'child');
      expect(config.pitch, 1.5);
      expect(config.rate, 0.8);
      expect(config.volume, 0.7);
    });
  });

  group('TtsVoices', () {
    test('Version is correct', () {
      expect(TtsVoices.version, '1.0.0');
    });
  });
}
