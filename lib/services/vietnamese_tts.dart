import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/flutter_tts_voice.dart';
import '../models/voice_config.dart';

enum TtsState { playing, stopped, paused, continued }

class VietnameseTts {
  final FlutterTts _flutterTts;
  TtsState _ttsState = TtsState.stopped;
  final String _vietnameseLocale = 'vi-VN';

  VoidCallback? onStateChanged;

  TtsState get ttsState => _ttsState;

  bool get isPlaying => _ttsState == TtsState.playing;
  bool get isStopped => _ttsState == TtsState.stopped;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWeb => kIsWeb;

  /// Initialize the TTS engine with Vietnamese language
  VietnameseTts() : _flutterTts = FlutterTts() {
    _initTts();
  }

  /// Initialize TTS with Vietnamese language and set handlers
  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_vietnameseLocale);
    await _flutterTts.awaitSpeakCompletion(true);

    // Set event handlers
    _flutterTts.setStartHandler(() {
      _ttsState = TtsState.playing;
      onStateChanged?.call();
    });

    _flutterTts.setCompletionHandler(() {
      _ttsState = TtsState.stopped;
      onStateChanged?.call();
    });

    _flutterTts.setCancelHandler(() {
      _ttsState = TtsState.stopped;
      onStateChanged?.call();
    });

    _flutterTts.setPauseHandler(() {
      _ttsState = TtsState.paused;
      onStateChanged?.call();
    });

    _flutterTts.setContinueHandler(() {
      _ttsState = TtsState.continued;
      onStateChanged?.call();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
      _ttsState = TtsState.stopped;
      onStateChanged?.call();
    });
  }

  /// Speak with fallback if Vietnamese voice is not available
  Future<void> speak(String text, VoiceConfig config) async {
    if (text.isEmpty) return;

    // Stop any ongoing speech
    if (isPlaying) {
      await stop();
    }

    // Apply voice configuration
    await _flutterTts.setVolume(config.volume);
    await _flutterTts.setPitch(config.pitch);
    await _flutterTts.setSpeechRate(config.rate);

    final selectedVoice = await findBestVoice(config);
    if (selectedVoice != null) {
      await _flutterTts.setVoice(selectedVoice.toStringMap());
    }

    // Speak the text
    await _flutterTts.speak(text);
  }

  /// Stop the current speech
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Pause the current speech
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  /// Returns the most suitable voice for the config (or fallback)
  Future<FlutterTtsVoice?> findBestVoice(VoiceConfig config) async {
    final voices = await _flutterTts.getVoices;
    final ttsVoices = List<FlutterTtsVoice>.from(
      voices.map((voice) {
        final map = <String, dynamic>{};
        (voice as Map).forEach((key, value) {
          map[key.toString()] = value;
        });
        return FlutterTtsVoice(map);
      }),
    );

    // 1. Match both gender and age
    FlutterTtsVoice? selectedVoice = ttsVoices.firstWhereOrNull(
      (v) => v.matchConfig(config),
    );
    // 2. Match either gender or age
    selectedVoice ??= ttsVoices.firstWhereOrNull(
      (v) => v.matchConfigPartial(config),
    );
    // 3. Any Vietnamese voice
    selectedVoice ??= ttsVoices.firstWhereOrNull((v) => v.isVietnamese);

    // 4. Fallback: use default voice
    selectedVoice ??= await getDefaultVoice();
    return selectedVoice;
  }

  /// Returns the default voice (or the first voice if not available)
  Future<FlutterTtsVoice?> getDefaultVoice() async {
    if (kIsWeb) {
      final voices = await _flutterTts.getVoices;
      if (voices.isNotEmpty) {
        final first = voices.first as Map;
        final map = <String, dynamic>{};
        first.forEach((key, value) {
          map[key.toString()] = value;
        });
        return FlutterTtsVoice(map);
      }
      debugPrint('No voices available');
      return null;
    }

    final voice = await _flutterTts.getDefaultVoice;
    if (voice == null || (voice is Map && voice.isEmpty)) {
      final voices = await _flutterTts.getVoices;
      if (voices.isNotEmpty) {
        final first = voices.first as Map;
        final map = <String, dynamic>{};
        first.forEach((key, value) {
          map[key.toString()] = value;
        });
        return FlutterTtsVoice(map);
      }
      debugPrint('No voices available');
      return null;
    }
    final map = <String, dynamic>{};
    (voice as Map).forEach((key, value) {
      map[key.toString()] = value.toString();
    });
    return FlutterTtsVoice(map);
  }

  /// Get a list of available VoiceConfig for the current platform
  Future<List<VoiceConfig>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices.map((voice) {
        final map = <String, dynamic>{};
        (voice as Map).forEach((key, value) {
          map[key.toString()] = value;
        });
        return VoiceConfig(
          gender: VoiceConfig.genderFromString(map['gender']),
          age: VoiceConfig.ageFromString(map['age']),
          pitch: 1.0, // Default, as pitch/rate/volume are not in voice meta
          rate: 0.5,
          volume: 1.0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting voice configs: $e');
      return [];
    }
  }

  /// Check if Vietnamese language is available
  Future<bool> isVietnameseAvailable() async {
    try {
      return await _flutterTts.isLanguageAvailable(_vietnameseLocale) as bool;
    } catch (e) {
      debugPrint('Error checking Vietnamese availability: $e');
      return false;
    }
  }

  /// Dispose the TTS resources
  void dispose() {
    _flutterTts.stop();
  }
}
