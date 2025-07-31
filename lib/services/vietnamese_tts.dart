import 'dart:async';
import 'dart:io' show Platform;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

  /// Check if there is a Vietnamese voice available
  Future<bool> hasVietnameseVoice() async {
    final voices = await _flutterTts.getVoices;
    return voices.any((voice) {
      final map = <String, dynamic>{};
      (voice as Map).forEach((key, value) {
        map[key.toString()] = value;
      });
      final locale = map['locale'] ?? map['language'] ?? '';
      return locale.toString().startsWith('vi');
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

    final voices = await _flutterTts.getVoices;
    Map<String, dynamic>? selectedVoice;

    // Convert all voices to Map<String, dynamic>
    final List<Map<String, dynamic>> mappedVoices =
        voices
            .map((voice) {
              final map = <String, dynamic>{};
              (voice as Map).forEach((key, value) {
                map[key.toString()] = value;
              });
              return map;
            })
            .toList()
            .cast<Map<String, dynamic>>();

    // List of prioritized conditions
    final List<bool Function(Map<String, dynamic>)> conditions = [
      // 1. Match both gender and age
      (map) =>
          (map['locale'] ?? map['language'] ?? '').toString().startsWith(
            'vi',
          ) &&
          (map['gender'] ?? '').toString().toLowerCase() ==
              config.gender.toLowerCase() &&
          (map['age'] ?? '').toString().toLowerCase() ==
              config.age.toLowerCase(),
      // 2. Match either gender or age
      (map) =>
          (map['locale'] ?? map['language'] ?? '').toString().startsWith(
            'vi',
          ) &&
          ((map['gender'] ?? '').toString().toLowerCase() ==
                  config.gender.toLowerCase() ||
              (map['age'] ?? '').toString().toLowerCase() ==
                  config.age.toLowerCase()),
      // 3. Any Vietnamese voice
      (map) =>
          (map['locale'] ?? map['language'] ?? '').toString().startsWith('vi'),
    ];

    // Find the voice that satisfies the highest priority condition
    for (final condition in conditions) {
      selectedVoice = mappedVoices.firstWhereOrNull(condition);
      if (selectedVoice != null && selectedVoice.isNotEmpty) break;
    }

    if (selectedVoice != null && selectedVoice.isNotEmpty) {
      final Map<String, String> stringVoiceMap = {};
      selectedVoice.forEach((key, value) {
        if (value != null) {
          stringVoiceMap[key.toString()] = value.toString();
        }
      });
      await _flutterTts.setVoice(stringVoiceMap);
    } else {
      // Fallback: use default voice
      final defaultVoice = await getDefaultVoice();
      await _flutterTts.setVoice(defaultVoice);
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

  Future<Map<String, String>> getDefaultVoice() async {
    if (kIsWeb) {
      // Web does not support getDefaultVoice, fallback to the first voice
      final voices = await _flutterTts.getVoices;
      if (voices.isNotEmpty) {
        final first = voices.first as Map;
        final Map<String, String> stringVoiceMap = {};
        first.forEach((key, value) {
          if (value != null) {
            stringVoiceMap[key.toString()] = value.toString();
          }
        });
        return stringVoiceMap;
      }
      debugPrint('No voices available');
      return {};
    }

    final voice = await _flutterTts.getDefaultVoice;
    if (voice == null || (voice is Map && voice.isEmpty)) {
      final voices = await _flutterTts.getVoices;
      if (voices.isNotEmpty) {
        final first = voices.first as Map;
        final Map<String, String> stringVoiceMap = {};
        first.forEach((key, value) {
          if (value != null) {
            stringVoiceMap[key.toString()] = value.toString();
          }
        });
        return stringVoiceMap;
      }
      debugPrint('No voices available');
      return {};
    }
    final Map<String, String> stringVoiceMap = {};
    (voice as Map).forEach((key, value) {
      if (value != null) {
        stringVoiceMap[key.toString()] = value.toString();
      }
    });
    return stringVoiceMap;
  }

  /// Get a list of all available voices
  Future<List<Map<String, dynamic>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices.map((voice) {
        final map = <String, dynamic>{};
        (voice as Map).forEach((key, value) {
          map[key.toString()] = value;
        });
        return map;
      }).toList();
    } catch (e) {
      debugPrint('Error getting voices: $e');
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
