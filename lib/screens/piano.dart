import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vibin/services/record_service.dart'; // Your singleton service
import 'package:vibin/services/achievements.dart';

class PianoKeyboard extends StatefulWidget {
  const PianoKeyboard({super.key});

  @override
  State<PianoKeyboard> createState() => _PianoKeyboardState();
}

class _PianoKeyboardState extends State<PianoKeyboard> {
  String? pressedNote;
  bool _isRecording = false;

  // Map to hold FlutterSoundPlayer instances for each note
  final Map<String, FlutterSoundPlayer> _notePlayers = {};
  final Map<String, String> _notePaths = {}; // asset path strings

  final List<String> _allNotes = [
    "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
    "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5"
  ];

  final RecorderService _recorderService = RecorderService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _setupAudioPlayers();
  }

  void _setupAudioPlayers() {
    for (var note in _allNotes) {
      final player = FlutterSoundPlayer();
      player.openPlayer();
      _notePlayers[note] = player;
    }
    print("All FlutterSound players ready for polyphony.");
    achievementManager.trackAction("Piano");
  }

  @override
  void dispose() {
    for (var player in _notePlayers.values) {
      player.closePlayer();
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> playSound(String note) async {
    setState(() => pressedNote = note);

    final player = _notePlayers[note];
    if (player == null) return;

    try {
      // Load asset as byte buffer
      final ByteData data = await rootBundle.load("assets/sounds/piano/$note.mp3");
      final Uint8List bytes = data.buffer.asUint8List();

      // Stop previous note if playing
      await player.stopPlayer();

      // Play from memory
      await player.startPlayer(
        fromDataBuffer: bytes,
        codec: Codec.mp3,
        whenFinished: () {
          if (mounted && pressedNote == note) setState(() => pressedNote = null);
        },
      );
    } catch (e) {
      print("Error playing $note: $e");
    }
  }

  Future<void> _toggleRecording() async {
    await _recorderService.toggleRecording(
          (status) {
        print(status);
        setState(() {
          _isRecording = _recorderService.isRecording;
        });
      },
      instrument: "Piano",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Piano"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_circle_rounded : Icons.fiber_manual_record,
              color: _isRecording ? Colors.red.shade700 : Colors.red,
            ),
            onPressed: _toggleRecording,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(2, (octave) => _buildOctave(octave + 4)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOctave(int octave) {
    final whiteNotes = ["C", "D", "E", "F", "G", "A", "B"];
    final blackNotes = {"C": "C#", "D": "D#", "F": "F#", "G": "G#", "A": "A#"};

    return SizedBox(
      width: whiteNotes.length * 80,
      height: 300,
      child: Stack(
        children: [
          Row(
            children: whiteNotes.map((note) {
              String fullNote = "$note$octave";
              bool isPressed = pressedNote == fullNote;

              return GestureDetector(
                onTap: () => playSound(fullNote),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 80,
                  height: 300,
                  decoration: BoxDecoration(
                    color: isPressed ? Colors.blue[200] : Colors.white,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(fullNote, style: const TextStyle(color: Colors.black)),
                  ),
                ),
              );
            }).toList(),
          ),
          ...whiteNotes.asMap().entries.map((entry) {
            int index = entry.key;
            String note = entry.value;

            if (blackNotes.containsKey(note)) {
              String fullNote = "${blackNotes[note]}$octave";
              bool isPressed = pressedNote == fullNote;

              return Positioned(
                left: (index * 80) + 55,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => playSound(fullNote),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 50,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isPressed ? Colors.blueGrey[700] : Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }).toList(),
        ],
      ),
    );
  }
}
