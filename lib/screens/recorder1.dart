// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart'; // Handles microphone access and saving
// import 'package:flutter/services.dart'; // For Haptic Feedback
//
// /// A simple, self-contained widget for recording audio and saving it
// /// to the application documents directory.
// class Recorder extends StatefulWidget {
//   /// Callback function that receives the path of the successfully saved file.
//   final ValueChanged<String> onRecordingSaved;
//
//   const Recorder({
//     super.key,
//     required this.onRecordingSaved,
//   });
//
//   @override
//   State<Recorder> createState() => _RecorderState();
// }
//
// class _RecorderState extends State<Recorder> {
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   bool _isRecording = false;
//   String? _statusMessage;
//
//   @override
//   void dispose() {
//     // Crucial: Dispose the recorder to free resources
//     _audioRecorder.dispose();
//     super.dispose();
//   }
//
//   /// Checks permissions, calculates a unique file path, and starts recording.
//   Future<void> _startRecording() async {
//     // 1. Check for microphone permission
//     if (await _audioRecorder.hasPermission()) {
//       final dir = await getApplicationDocumentsDirectory();
//
//       // Changed file name prefix to the generic "Audio_Track" for multi-instrument use.
//       final filePath = '${dir.path}/Audio_Track_${DateTime.now().millisecondsSinceEpoch}.wav';
//
//       // 2. Configure and start the recording
//       // Use AudioEncoder.wav (uncompressed PCM) for high quality.
//       await _audioRecorder.start(
//         const RecordConfig(encoder: AudioEncoder.wav),
//         path: filePath,
//       );
//
//       // 3. Update UI state
//       setState(() {
//         _isRecording = true;
//         _statusMessage = "Recording...";
//       });
//       HapticFeedback.heavyImpact();
//     } else {
//       setState(() {
//         _statusMessage = "Microphone permission denied.";
//       });
//       print("Microphone permission denied.");
//     }
//   }
//
//   /// Stops the current recording and returns the path to the saved file.
//   Future<void> _stopRecording() async {
//     final path = await _audioRecorder.stop();
//
//     setState(() {
//       _isRecording = false;
//     });
//
//     if (path != null) {
//       widget.onRecordingSaved(path); // Call the callback with the saved file path
//       HapticFeedback.mediumImpact();
//       setState(() {
//         _statusMessage = "Recording saved!";
//       });
//     } else {
//       setState(() {
//         _statusMessage = "Recording failed to save.";
//       });
//     }
//   }
//
//   /// Toggles between starting and stopping the recording.
//   void _toggleRecording() {
//     if (_isRecording) {
//       _stopRecording();
//     } else {
//       _startRecording();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // Status Text
//         if (_statusMessage != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               _statusMessage!,
//               style: TextStyle(
//                 color: _isRecording ? Colors.red : Colors.green,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//
//         // Recording Button
//         FloatingActionButton.extended(
//           heroTag: "recorderBtn", // Required if multiple FloatingActionButtons are on the screen
//           onPressed: _toggleRecording,
//           label: Text(_isRecording ? "STOP" : "RECORD"),
//           icon: Icon(
//             _isRecording ? Icons.stop : Icons.mic,
//             color: Colors.white,
//           ),
//           backgroundColor: _isRecording ? Colors.red[700] : Colors.blue,
//           // Add a subtle animation when recording
//           elevation: _isRecording ? 8.0 : 4.0,
//         ),
//       ],
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:vibin/services/auth_service.dart';

class Recorder extends StatefulWidget {
  final ValueChanged<String> onRecordingSaved;

  const Recorder({
    super.key,
    required this.onRecordingSaved,
  });

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _player.openPlayer(); // open player early
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _player.closePlayer(); // free audio resources
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final filePath =
          '${dir.path}/Audio_Track_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _statusMessage = "Recording...";
      });
      HapticFeedback.heavyImpact();
    } else {
      setState(() {
        _statusMessage = "Microphone permission denied.";
      });
    }
  }

  // Future<void> _stopRecording() async {
  //   final path = await _audioRecorder.stop();
  //
  //   setState(() {
  //     _isRecording = false;
  //   });
  //
  //   if (path != null && await File(path).exists()) {
  //     widget.onRecordingSaved(path);
  //     setState(() => _statusMessage = "Recording saved!");
  //
  //     // ✅ Auto-play the file immediately
  //     await _playRecording(path);
  //   } else {
  //     setState(() => _statusMessage = "Recording failed to save.");
  //   }
  // }
  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();

    setState(() {
      _isRecording = false;
    });

    if (path != null && await File(path).exists()) {
      // Save locally first (existing behavior)
      widget.onRecordingSaved(path);
      setState(() => _statusMessage = "Recording saved locally!");

      // ✅ Upload to Supabase
      try {
        final authServe = Provider.of<AuthServe>(context, listen: false);
        final file = File(path);
        final signedUrl = await authServe.uploadAudio(file);

        if (signedUrl != null) {
          setState(() => _statusMessage = "Recording uploaded!");
          print("Supabase Signed URL: $signedUrl");

          // Optional: play from Supabase URL
          await _playRecording(signedUrl, isNetwork: true);
        } else {
          setState(() => _statusMessage = "Upload failed.");
        }
      } catch (e) {
        setState(() => _statusMessage = "Upload error: $e");
        print(e);
      }

      // ✅ Auto-play the local file immediately (optional)
      await _playRecording(path);
    } else {
      setState(() => _statusMessage = "Recording failed to save.");
    }
  }


  // Future<void> _playRecording(String path, {bool isNetwork = false}) async {
  //   if (_isPlaying) {
  //     await _player.stopPlayer();
  //     setState(() => _isPlaying = false);
  //     return;
  //   }
  //
  //   setState(() {
  //     _statusMessage = "Playing...";
  //     _isPlaying = true;
  //   });
  //
  //   await _player.startPlayer(
  //     fromURI: path,
  //     whenFinished: () {
  //       setState(() {
  //         _isPlaying = false;
  //         _statusMessage = "Playback finished";
  //       });
  //     },
  //   );
  // }
  Future<void> _playRecording(String path, {bool isNetwork = false}) async {
    if (_isPlaying) {
      await _player.stopPlayer();
      setState(() => _isPlaying = false);
      return;
    }

    setState(() {
      _statusMessage = "Playing...";
      _isPlaying = true;
    });

    await _player.startPlayer(
      fromURI: path,
      whenFinished: () {
        setState(() {
          _isPlaying = false;
          _statusMessage = "Playback finished";
        });
      },
    );
  }


  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: _isRecording
                    ? Colors.red
                    : _isPlaying
                    ? Colors.orange
                    : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        FloatingActionButton.extended(
          heroTag: "recorderBtn",
          onPressed: _toggleRecording,
          label: Text(_isRecording ? "STOP" : "RECORD"),
          icon: Icon(
            _isRecording ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
          backgroundColor: _isRecording ? Colors.red[700] : Colors.blue,
          elevation: _isRecording ? 8.0 : 4.0,
        ),
      ],
    );
  }
}
