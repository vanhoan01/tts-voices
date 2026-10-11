# TTS Voices Example

A demo Flutter app for the `tts_voices` package. It reads Vietnamese text aloud with `VietnameseTts` and lets you adjust the voice configuration live.

## Features

- Enter any Vietnamese text and play, pause or stop speech
- Choose voice **gender** (`male`, `female`) and **age** (`child`, `teen`, `adult`, `senior`)
- Adjust **pitch** (0.5 – 2.0), **rate** (0.0 – 1.0) and **volume** (0.0 – 1.0) with sliders
- Shows a status message when no Vietnamese voice is installed and a fallback voice is used

## Running the example

The app depends on the package via a local path (`tts_voices: path: ../`), so run it from this folder:

```bash
cd example
flutter pub get
flutter run            # pick a device, or:
flutter run -d chrome  # Web
```

Supported platforms: Android and Web (see the root [README](../README.md)).

> **Note:** Speech uses the device's built-in TTS engine through `flutter_tts`. For Vietnamese output, install a Vietnamese voice on the device (e.g. Google Text-to-Speech with Vietnamese voice data on Android). If none is available, the app falls back to the default voice and shows a warning.

## How it works

The demo code lives in [lib/main.dart](lib/main.dart). The core usage is:

```dart
import 'package:tts_voices/tts_voices.dart';

final tts = VietnameseTts();

// Rebuild the UI when playback state changes (playing, paused, stopped...)
tts.onStateChanged = () => setState(() {});

final config = VoiceConfig(
  gender: Gender.female,
  age: Age.adult,
  pitch: 1.0,
  rate: 0.5,
  volume: 1.0,
);

// Check which voice will be used (Vietnamese or fallback)
final voice = await tts.findBestVoice(config);
if (voice != null && !voice.isVietnamese) {
  debugPrint('Vietnamese TTS unavailable, using ${voice.locale} instead.');
}

await tts.speak('Xin chào, tôi là trợ lý của bạn.', config);
await tts.pause();
await tts.stop();

// When the widget is disposed
tts.dispose();
```

### Voice selection order

`findBestVoice` picks a voice in this order:

1. A Vietnamese voice matching both gender and age
2. A Vietnamese voice matching gender or age
3. Any Vietnamese voice
4. The platform's default voice (fallback)
