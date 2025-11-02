import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  final List<String> _stringNotes = [
    "guitar_E_low.wav",
    "guitar_A.wav",
    "guitar_D.wav",
    "guitar_G.wav",
    "guitar_B.wav",
    "guitar_E_high.wav",
  ];

  // A list of AudioPlayer instances for polyphony
  final List<AudioPlayer> _players = List.generate(6, (index) => AudioPlayer());

  int? _lastPlayedIndex;

  // Define chord configurations
  static const Map<String, List<int>> _chords = {
    "C": [1, 2, 3, 4, 5], // Excludes low E (string 0)
    "G": [0, 1, 2, 3, 4, 5], // All strings
    "Am": [1, 2, 3, 4, 5], // Excludes low E (string 0)
    "F": [0, 1, 2, 3, 4], // Excludes high E (string 5)
  };

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    for (var player in _players) {
      player.dispose();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  // Plays a single string using its dedicated player
  void _playString(int index) async {
    // Stop any previous sound on this specific player
    await _players[index].stop();
    await _players[index].play(AssetSource("sounds/guitar/${_stringNotes[index]}"));
  }

  // Plays a strum with a specified starting and ending string, and a direction
  void _playStrum(int start, int end, int step, {double speedFactor = 1.0, List<int>? stringsToPlay}) {
    List<int> strings = stringsToPlay ?? [];
    if (strings.isEmpty) {
      for (int i = start; step > 0 ? i <= end : i >= end; i += step) {
        strings.add(i);
      }
    }

    for (int i = 0; i < strings.length; i++) {
      final index = strings[i];
      int delayMs = (100 / speedFactor * (i)).clamp(0, 250).toInt();
      Future.delayed(Duration(milliseconds: delayMs), () {
        _playString(index);
      });
    }
  }

  // Handles the drag gesture for strumming
  void _onStrum(DragUpdateDetails details, BoxConstraints constraints) {
    final stringHeight = constraints.maxHeight / _stringNotes.length;
    final y = details.localPosition.dy;
    int index = (y ~/ stringHeight).clamp(0, _stringNotes.length - 1);

    if (_lastPlayedIndex != index) {
      final delta = details.delta.dy;
      final movingDown = delta > 0;
      double speedFactor = delta.abs() / stringHeight;
      if (speedFactor < 1) speedFactor = 1;

      // Play the first string immediately
      _playString(index);

      // Trigger the rest of the strum
      if (movingDown && index < _stringNotes.length - 1) {
        _playStrum(index + 1, _stringNotes.length - 1, 1, speedFactor: speedFactor);
      } else if (!movingDown && index > 0) {
        _playStrum(index - 1, 0, -1, speedFactor: speedFactor);
      }

      _lastPlayedIndex = index;
    }
  }

  // Plays a pre-defined chord
  void _playChord(String chordName) {
    final strings = _chords[chordName];
    if (strings != null) {
      // Play a quick strum over the chord strings
      _playStrum(0, 0, 0, stringsToPlay: strings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Column(
        children: [
          // Chord buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
            child: Wrap(
              spacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _playChord("C"),
                  child: const Text("C"),
                ),
                ElevatedButton(
                  onPressed: () => _playChord("G"),
                  child: const Text("G"),
                ),
                ElevatedButton(
                  onPressed: () => _playChord("Am"),
                  child: const Text("Am"),
                ),
                ElevatedButton(
                  onPressed: () => _playChord("F"),
                  child: const Text("F"),
                ),
              ],
            ),
          ),
          // Strings
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) => _onStrum(details, constraints),
                  onPanEnd: (_) => _lastPlayedIndex = null,
                  child: Column(
                    children: List.generate(_stringNotes.length, (i) {
                      return InkWell(
                        onTap: () => _playString(i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 12,
                          ),
                          height:
                          (constraints.maxHeight / _stringNotes.length) - 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.brown[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "String ${i + 1}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}