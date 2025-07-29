# TTS Voices

A Flutter package that provides text-to-speech (TTS) Vietnamese functionality with configurable AI avatar voices for dynamic character-based speech synthesis.

## Features

- **Configurable Voice Parameters**: Support for gender (male, female), age (child, adult, old), and pitch (low, standard, high) combinations
- **AI Avatar Characters**: Pre-defined character voices with distinct personalities:
  - **Natra**: Male, child, high pitch
  - **Dat Ky**: Female, adult, normal pitch  
  - **Khuong Tu Nha**: Male, old, low pitch
  - **Standard**: Male, adult, normal pitch (fallback voice)
- **Context-Aware Voice Selection**: Adapts voice based on user preferences and timing
- **Cross-Platform Support**: Consistent voice experience across Web and Android platforms
- **Fallback System**: Automatic fallback to Standard voice for unsupported scenarios

## Getting Started

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  tts_voices: ^0.0.1
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Text-to-Speech

```dart
import 'package:tts_voices/tts_voices.dart';

// Create a voice configuration
final voiceConfig = VoiceConfig(
  gender: Gender.male,
  age: Age.adult,
  pitch: Pitch.standard,
);

// Speak text with the configured voice
await speak("Xin chào, tôi là trợ lý Tử Vi của bạn.", voiceConfig);
```

### Using Pre-defined Character Voices

```dart
// Use Natra character voice (male, child, high)
await speak("Chào! Natra đây! Hôm nay cậu muốn hỏi gì về tử vi?", VoiceConfig.natra());

// Use Dat Ky character voice (female, adult, normal)
await speak("Xin chào, ta là Đát Kỷ. Ta sẽ giúp ngươi giải đáp những thắc mắc về vận mệnh.", VoiceConfig.datKy());

// Use Khuong Tu Nha character voice (male, old, high)
await speak("Lão phu Khương Tử Nha đây. Hãy đến gần và hỏi lão về số phận của ngươi.", VoiceConfig.khuongTuNha());

// Fallback to Standard voice
await speak("Xin chào, tôi là trợ lý tử vi của bạn.", VoiceConfig.standard());
```

## Implementation Roadmap

### Phase 1: Standard Voice (Current)
- ✅ Implement `Future<void> speak(String text, VoiceConfig config)` function
- ✅ Standard Male voice using flutter_tts
- ✅ Cross-platform compatibility (Web and Android)

### Phase 2: Advanced Character Voices (Upcoming)
- 🔄 Integration with Google Cloud Text-To-Speech SDK
- 🔄 Implementation of Natra, Dat Ky, and Khuong Tu Nha character voices
- 🔄 Context-dependent voice selection logic
- 🔄 Enhanced voice quality and character personality matching

## Platform Support

| Platform | Status | Implementation |
|----------|--------|----------------|
| Android  | ✅ Supported | flutter_tts |
| Web      | ✅ Supported | flutter_tts |
| iOS      | 🔄 Planned | flutter_tts |

## Additional Information

This package is designed for applications requiring dynamic, character-based text-to-speech functionality. The voice selection system automatically adapts based on user preferences and context, providing an immersive audio experience.

For issues, feature requests, or contributions, please visit our repository or contact the development team.
