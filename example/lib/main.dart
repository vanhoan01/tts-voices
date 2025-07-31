import 'package:flutter/material.dart';
import 'package:tts_voices/tts_voices.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vietnamese TTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TtsVoiceDemo(),
    );
  }
}

class TtsVoiceDemo extends StatefulWidget {
  const TtsVoiceDemo({super.key});

  @override
  State<TtsVoiceDemo> createState() => _TtsVoiceDemoState();
}

class _TtsVoiceDemoState extends State<TtsVoiceDemo> {
  final VietnameseTts _tts = VietnameseTts();
  final TextEditingController _textController = TextEditingController();

  // Voice configuration
  String _gender = 'female';
  String _age = 'adult';
  double _pitch = 1.0;
  double _rate = 0.5;
  double _volume = 1.0;

  String _statusMessage = '';

  TtsState get ttsState => _tts.ttsState;

  @override
  void initState() {
    super.initState();
    _tts.onStateChanged = () {
      setState(() {}); // Update the UI when TTS state changes
    };
    _checkTtsAvailability();
  }

  Future<void> _checkTtsAvailability() async {
    bool isAvailable = await _tts.isVietnameseAvailable();

    String status;
    if (isAvailable) {
      status = '';
    } else {
      final defaultVoice = await _tts.getDefaultVoice();
      final fallbackLang =
          defaultVoice['locale'] ??
          defaultVoice['language'] ??
          defaultVoice['name'] ??
          'unknown';
      status = 'Vietnamese TTS unavailable, using $fallbackLang instead.';
    }

    setState(() {
      _statusMessage = status;
    });
  }

  @override
  void dispose() {
    _tts.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _speak() async {
    final config = VoiceConfig(
      gender: _gender,
      age: _age,
      pitch: _pitch,
      rate: _rate,
      volume: _volume,
    );

    try {
      await _tts.speak(_textController.text, config);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _stop() async {
    await _tts.stop();
  }

  void _pause() async {
    await _tts.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vietnamese TTS'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text input
              TextField(
                controller: _textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter Vietnamese text to speak',
                ),
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
              ),
              const SizedBox(height: 16),

              // Status message
              if (_statusMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 16),

              // Control buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ttsState == TtsState.playing || ttsState == TtsState.continued
                      ? ElevatedButton.icon(
                        onPressed: _pause,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      )
                      : ElevatedButton.icon(
                        onPressed: _speak,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ElevatedButton.icon(
                    onPressed: _stop,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Gender selection
              Row(
                children: [
                  const Text('Gender:'),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Female'),
                    selected: _gender == 'female',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _gender = 'female';
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Male'),
                    selected: _gender == 'male',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _gender = 'male';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Age selection
              Row(
                children: [
                  const Text('Age:'),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Child'),
                    selected: _age == 'child',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _age = 'child';
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Adult'),
                    selected: _age == 'adult',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _age = 'adult';
                        });
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Senior'),
                    selected: _age == 'senior',
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _age = 'senior';
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Voice controls
              const Text('Pitch:'),
              Slider(
                value: _pitch,
                min: 0.5,
                max: 2.0,
                divisions: 15,
                label: _pitch.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _pitch = value;
                  });
                },
              ),

              const Text('Rate:'),
              Slider(
                value: _rate,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: _rate.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _rate = value;
                  });
                },
              ),

              const Text('Volume:'),
              Slider(
                value: _volume,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: _volume.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _volume = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
