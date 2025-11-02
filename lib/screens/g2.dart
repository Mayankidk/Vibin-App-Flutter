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

  // Number of AudioPlayers per string to allow overlapping notes
  final int _poolSize = 3;
  late final List<List<AudioPlayer>> _playerPool;
  late final List<int> _poolIndex;

  int? _lastPlayedIndex;
  double _lastDragPosition = 0;
  bool _isDragging = false;

  // Minimum movement threshold to prevent accidental triggers
  static const double _movementThreshold = 10.0;

  // Chord definitions
  static const Map<String, List<int>> _chords = {
    "C": [1, 2, 3, 4, 5],
    "G": [0, 1, 2, 3, 4, 5],
    "Am": [1, 2, 3, 4, 5],
    "F": [0, 1, 2, 3, 4, 5],
  };

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Initialize player pool
    _playerPool = List.generate(
      _stringNotes.length,
          (_) => List.generate(_poolSize, (_) => AudioPlayer()),
    );
    _poolIndex = List.filled(_stringNotes.length, 0);

    // Preload all audio assets into each player
    for (int s = 0; s < _stringNotes.length; s++) {
      for (var player in _playerPool[s]) {
        player.setSource(AssetSource("sounds/guitar/${_stringNotes[s]}"));
      }
    }
  }

  @override
  void dispose() {
    for (var pool in _playerPool) {
      for (var player in pool) {
        player.dispose();
      }
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  // Play a string using the player pool
  void _playString(int index) async {
    final pool = _playerPool[index];
    int i = _poolIndex[index];

    await pool[i].stop(); // stop only this player instance
    await pool[i].play(
      AssetSource("sounds/guitar/${_stringNotes[index]}"),
      mode: PlayerMode.lowLatency,
    );

    // Move to next player in the pool
    _poolIndex[index] = (i + 1) % _poolSize;
  }

  // Strum over a range of strings
  void _playStrum(int start, int end, int step,
      {double speedFactor = 1.0, List<int>? stringsToPlay}) {
    List<int> strings = stringsToPlay ?? [];
    if (strings.isEmpty) {
      for (int i = start; step > 0 ? i <= end : i >= end; i += step) {
        strings.add(i);
      }
    }

    for (int i = 0; i < strings.length; i++) {
      final idx = strings[i];
      int delayMs = (100 / speedFactor * i).clamp(0, 250).toInt();
      Future.delayed(Duration(milliseconds: delayMs), () {
        _playString(idx);
      });
    }
  }

  // Handle drag start
  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _lastDragPosition = details.localPosition.dy;
    _lastPlayedIndex = null;
  }

  // Handle drag strumming - ONLY TOUCHED STRINGS (no cascading)
  void _onStrum(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isDragging) return;

    final stringHeight = constraints.maxHeight / _stringNotes.length;
    final y = details.localPosition.dy;
    int index = (y ~/ stringHeight).clamp(0, _stringNotes.length - 1);

    // Only play the string you're currently touching
    if (_lastPlayedIndex != index) {
      final totalMovement = (y - _lastDragPosition).abs();

      // Only trigger if movement is significant enough
      if (totalMovement >= _movementThreshold) {
        _playString(index);
        _lastPlayedIndex = index;
        // REMOVED: All cascading strum logic
      }
    }
  }

  // Handle drag end
  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _lastPlayedIndex = null;
    _lastDragPosition = 0;
  }

  // Play a chord
  void _playChord(String chordName) {
    final strings = _chords[chordName];
    if (strings != null) {
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
                ElevatedButton(onPressed: () => _playChord("C"), child: const Text("C")),
                ElevatedButton(onPressed: () => _playChord("G"), child: const Text("G")),
                ElevatedButton(onPressed: () => _playChord("Am"), child: const Text("Am")),
                ElevatedButton(onPressed: () => _playChord("F"), child: const Text("F")),
              ],
            ),
          ),
          // Strings
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: (details) => _onStrum(details, constraints),
                  onPanEnd: _onPanEnd,
                  child: Column(
                    children: List.generate(_stringNotes.length, (i) {
                      return InkWell(
                        onTap: () => _playString(i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          height: (constraints.maxHeight / _stringNotes.length) - 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.brown[400],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 16),
                          child: Text(
                            "String ${i + 1}",
                            style: const TextStyle(fontSize: 18, color: Colors.white),
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