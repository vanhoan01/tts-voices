import 'voice_config.dart';

/// Proxy class for a Flutter TTS voice map
class FlutterTtsVoice {
  final Map<String, dynamic> _data;
  FlutterTtsVoice(this._data);

  Map<String, dynamic> get data => _data;
  String get locale => (_data['locale'] ?? _data['language'] ?? '').toString();
  String get gender => (_data['gender'] ?? '').toString().toLowerCase();
  String get age => (_data['age'] ?? '').toString().toLowerCase();
  bool get isVietnamese => locale.startsWith('vi');

  // Convert this voice to Map for setVoice
  Map<String, String> toStringMap() {
    final result = <String, String>{};
    _data.forEach((key, value) {
      if (value != null) {
        result[key.toString()] = value.toString();
      }
    });
    return result;
  }

  // Create FlutterTtsVoice from Map
  static FlutterTtsVoice fromStringMap(Map<String, String> map) {
    final data = <String, dynamic>{};
    map.forEach((key, value) {
      data[key] = value;
    });
    return FlutterTtsVoice(data);
  }

  // Returns true if this voice matches the config (both gender and age)
  bool matchConfig(VoiceConfig config) {
    final genderEnum = VoiceConfig.genderFromString(gender);
    final ageEnum = VoiceConfig.ageFromString(age);
    final genderMatch = genderEnum == config.gender;
    final ageMatch = ageEnum == config.age;
    return isVietnamese && genderMatch && ageMatch;
  }

  // Returns true if this voice matches either gender or age
  bool matchConfigPartial(VoiceConfig config) {
    final genderEnum = VoiceConfig.genderFromString(gender);
    final ageEnum = VoiceConfig.ageFromString(age);
    final genderMatch = genderEnum == config.gender;
    final ageMatch = ageEnum == config.age;
    return isVietnamese && (genderMatch || ageMatch);
  }
}
