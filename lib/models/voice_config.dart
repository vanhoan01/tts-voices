enum Gender { male, female, unknown }

enum Age { child, teen, adult, senior, unknown }

class VoiceConfig {
  /// Gender of the voice (male/female)
  final Gender gender;

  /// Age characteristics of the voice
  final Age age;

  /// Pitch value between 0.5 and 2.0
  final double pitch;

  /// Rate value between 0.0 and 1.0
  final double rate;

  /// Volume value between 0.0 and 1.0
  final double volume;

  const VoiceConfig({
    this.gender = Gender.female,
    this.age = Age.adult,
    this.pitch = 1.0,
    this.rate = 0.5,
    this.volume = 1.0,
  });

  // Helper to parse from string (for mapping from TTS voice data)
  static Gender genderFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.unknown;
    }
  }

  static Age ageFromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'child':
        return Age.child;
      case 'teen':
        return Age.teen;
      case 'adult':
        return Age.adult;
      case 'senior':
        return Age.senior;
      default:
        return Age.unknown;
    }
  }
}
