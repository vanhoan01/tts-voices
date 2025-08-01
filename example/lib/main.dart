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
  Gender _gender = Gender.female;
  Age _age = Age.adult;
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
  }

  Future<void> _updateVoiceStatus(VoiceConfig config) async {
    final bestVoice = await _tts.findBestVoice(config);

    String status;
    if (bestVoice != null && bestVoice.isVietnamese) {
      status = '';
    } else if (bestVoice != null) {
      final fallbackLang =
          bestVoice.locale.isNotEmpty
              ? bestVoice.locale
              : (bestVoice.data['language'] ??
                      bestVoice.data['name'] ??
                      'unknown')
                  .toString();
      status = 'Vietnamese TTS unavailable, using $fallbackLang instead.';
    } else {
      status = 'No TTS voice available.';
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
      await _updateVoiceStatus(config);
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
                  ...Gender.values
                      .where((g) => g != Gender.unknown)
                      .map(
                        (g) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                              g.name[0].toUpperCase() + g.name.substring(1),
                            ),
                            selected: _gender == g,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _gender = g;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 16),

              // Age selection
              Row(
                children: [
                  const Text('Age:'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ...Age.values
                              .where((a) => a != Age.unknown)
                              .map(
                                (a) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(
                                      a.name[0].toUpperCase() +
                                          a.name.substring(1),
                                    ),
                                    selected: _age == a,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _age = a;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
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
