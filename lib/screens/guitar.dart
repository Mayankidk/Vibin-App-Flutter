import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vibin/services/record_service.dart';
import 'package:vibin/services/achievements.dart';

class GuitarScreen extends StatefulWidget {
  const GuitarScreen({super.key});

  @override
  State<GuitarScreen> createState() => _GuitarScreenState();
}

class _GuitarScreenState extends State<GuitarScreen> {
  // Guitar strings (asset paths)
  final List<String> _stringNotes = [
    "assets/sounds/guitar/guitar_E_low.wav",
    "assets/sounds/guitar/guitar_A.wav",
    "assets/sounds/guitar/guitar_D.wav",
    "assets/sounds/guitar/guitar_G.wav",
    "assets/sounds/guitar/guitar_B.wav",
    "assets/sounds/guitar/guitar_E_high.wav",
  ];

  // Player pool per string for overlapping notes
  final int _poolSize = 3;
  late final List<List<FlutterSoundPlayer>> _playerPool;
  late final List<int> _poolIndex;
  late final List<List<String>> _playerPaths;

  // Drag tracking
  int? _lastPlayedIndex;
  double _lastDragPosition = 0;
  bool _isDragging = false;
  static const double _movementThreshold = 10.0;
  String? _recordStatus;


  // Chords
  static const Map<String, List<int>> _chords = {
    "C": [1, 2, 3, 4, 5],
    "G": [0, 1, 2, 3, 4, 5],
    "Am": [1, 2, 3, 4, 5],
    "F": [0, 1, 2, 3, 4, 5],
  };

  // Last recorded file

  @override
  void initState() {
    super.initState();
    // achievementManager.trackAction("Guitar");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _poolIndex = List.filled(_stringNotes.length, 0);
    _playerPool = List.generate(
        _stringNotes.length,
            (_) => List.generate(_poolSize, (_) => FlutterSoundPlayer()));
    _playerPaths = List.generate(_stringNotes.length, (_) => List.filled(_poolSize, ""));

    _initPlayers();
  }

  // Future<void> _initPlayers() async {
  //   final tempDir = await getTemporaryDirectory();
  //
  //   for (int s = 0; s < _stringNotes.length; s++) {
  //     for (int i = 0; i < _poolSize; i++) {
  //       final player = _playerPool[s][i];
  //       await player.openPlayer();
  //       // Copy asset to temp file
  //       final bytes = await rootBundle.load(_stringNotes[s]);
  //       final file = File('${tempDir.path}/${_stringNotes[s].split("/").last}-$i.wav');
  //       await file.writeAsBytes(bytes.buffer.asUint8List());
  //       _playerPaths[s][i] = file.path;
  //     }
  //   }
  // }
  Future<void> _initPlayers() async {
    final tempDir = await getTemporaryDirectory();

    for (int s = 0; s < _stringNotes.length; s++) {
      for (int i = 0; i < _poolSize; i++) {
        final player = _playerPool[s][i];
        await player.openPlayer();

        // Correctly load asset
        final bytes = await rootBundle.load(_stringNotes[s]);
        final file = File('${tempDir.path}/${_stringNotes[s].split("/").last}-$i.wav');
        await file.writeAsBytes(bytes.buffer.asUint8List());

        _playerPaths[s][i] = file.path;

        // Optional: warm up
        await player.startPlayer(
          fromURI: _playerPaths[s][i],
          codec: Codec.pcm16WAV,
          whenFinished: () {},
        );
        await player.stopPlayer();
      }
    }
    achievementManager.trackAction("Guitar");
  }



  @override
  void dispose() {
    for (var pool in _playerPool) {
      for (var player in pool) {
        player.closePlayer();
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

  // Play a single string
  // void _playString(int index) async {
  //   final pool = _playerPool[index];
  //   final paths = _playerPaths[index];
  //   int i = _poolIndex[index];
  //   final player = pool[i];
  //   final path = paths[i];
  //
  //   if (player.isPlaying) await player.stopPlayer();
  //
  //   await player.startPlayer(
  //     fromURI: path,
  //     codec: Codec.pcm16WAV,
  //     whenFinished: () {},
  //   );
  //
  //   _poolIndex[index] = (i + 1) % _poolSize;
  // }
  // void _playString(int index) async {
  //   //achievementManager.trackAction("Guitar");
  //   final pool = _playerPool[index];
  //   final paths = _playerPaths[index];
  //   int i = _poolIndex[index];
  //
  //   final player = pool[i];
  //   final path = paths[i];
  //
  //   if (player.isPlaying) await player.stopPlayer();
  //
  //   await player.startPlayer(
  //     fromURI: path,
  //     codec: Codec.pcm16WAV,
  //     whenFinished: () {},
  //   );
  //
  //   _poolIndex[index] = (i + 1) % _poolSize;
  // }

  void _playString(int index) async {
    final pool = _playerPool[index];
    final paths = _playerPaths[index];
    int i = _poolIndex[index];

    final player = pool[i];
    final path = paths[i];

    if (player.isPlaying) await player.stopPlayer();

    await player.startPlayer(
      fromURI: path,
      codec: Codec.pcm16WAV,
      whenFinished: () {},
    );

    _poolIndex[index] = (i + 1) % _poolSize;
  }



  // Play multiple strings for chord or strum
  void _playStrum({List<int>? stringsToPlay, double speedFactor = 1.0}) {
    if (stringsToPlay == null || stringsToPlay.isEmpty) return;

    for (int i = 0; i < stringsToPlay.length; i++) {
      final idx = stringsToPlay[i];
      int delayMs = (100 / speedFactor * i).clamp(0, 250).toInt();
      Future.delayed(Duration(milliseconds: delayMs), () => _playString(idx));
    }
  }

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
    _lastDragPosition = details.localPosition.dy;
    _lastPlayedIndex = null;
  }

  void _onStrum(DragUpdateDetails details, BoxConstraints constraints) {
    if (!_isDragging) return;

    final stringHeight = constraints.maxHeight / _stringNotes.length;
    final y = details.localPosition.dy;
    int index = (y ~/ stringHeight).clamp(0, _stringNotes.length - 1);

    if (_lastPlayedIndex != index) {
      final totalMovement = (y - _lastDragPosition).abs();
      if (totalMovement >= _movementThreshold) {
        _playString(index);
        _lastPlayedIndex = index;
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    _lastPlayedIndex = null;
    _lastDragPosition = 0;
  }

  void _playChord(String chordName) {
    final strings = _chords[chordName];
    if (strings != null) _playStrum(stringsToPlay: strings);
  }

  void _onRecordButtonPressed() {
    RecorderService().toggleRecording((status) {
      setState(() => _recordStatus = status);
    },instrument:"Guitar");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      body: Column(
        children: [
          const SizedBox(height: 12),
          // Chord buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
            child: Wrap(
              spacing: 12,
              children: [
                ElevatedButton(onPressed: () => _playChord("C"), child: const Text("C")),
                ElevatedButton(onPressed: () => _playChord("G"), child: const Text("G")),
                ElevatedButton(onPressed: () => _playChord("Am"), child: const Text("Am")),
                ElevatedButton(onPressed: () => _playChord("F"), child: const Text("F")),
                ElevatedButton(onPressed: _onRecordButtonPressed, child: Icon(
                  RecorderService().isRecording ? Icons.stop : Icons.mic))
              ],
            ),
          ),

          // Guitar strings
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
