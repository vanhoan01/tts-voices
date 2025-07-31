class VoiceConfig {
  /// Gender of the voice (male/female)
  final String gender;

  /// Age characteristics of the voice
  final String age;

  /// Pitch value between 0.5 and 2.0
  final double pitch;

  /// Rate value between 0.0 and 1.0
  final double rate;

  /// Volume value between 0.0 and 1.0
  final double volume;

  const VoiceConfig({
    this.gender = 'female',
    this.age = 'adult',
    this.pitch = 1.0,
    this.rate = 0.5,
    this.volume = 1.0,
  });
}
