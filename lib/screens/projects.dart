// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';
//
// // Renamed from LoopRecorderPage to ProjectPage
// class ProjectPage extends StatefulWidget {
//   const ProjectPage({super.key});
//
//   @override
//   // Renamed the state class
//   State<ProjectPage> createState() => _ProjectPageState();
// }
//
// // Renamed the state class
// class _ProjectPageState extends State<ProjectPage> {
//   // Renamed to better reflect content: Recordings for a Project
//   List<FileSystemEntity> _projectRecordings = [];
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   String? _currentlyPlaying;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadProjectRecordings();
//
//     // Set the completion listener once
//     _audioPlayer.onPlayerComplete.listen((_) {
//       setState(() => _currentlyPlaying = null);
//     });
//   }
//
//   // Renamed function
//   Future<void> _loadProjectRecordings() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final files = dir.listSync()
//         .where((file) => file.path.endsWith(".wav"))
//         .toList()
//       ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified)); // newest first
//
//     setState(() {
//       _projectRecordings = files; // Updated variable name
//     });
//   }
//
//   Future<void> _playRecording(String path) async {
//     // Check if the file is already playing (for play/pause functionality)
//     if (_currentlyPlaying == path) {
//       await _audioPlayer.pause();
//       setState(() => _currentlyPlaying = null);
//     } else {
//       await _audioPlayer.stop();
//       await _audioPlayer.play(DeviceFileSource(path));
//       setState(() => _currentlyPlaying = path);
//     }
//   }
//
//   // Renamed function, calls renamed loader function
//   Future<void> _deleteRecording(FileSystemEntity file) async {
//     // Stop playback if the file being deleted is currently playing
//     if (_currentlyPlaying == file.path) {
//       await _audioPlayer.stop();
//       _currentlyPlaying = null;
//     }
//     await file.delete();
//     _loadProjectRecordings();
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Project Recordings 🎙")), // Updated title
//       body: _projectRecordings.isEmpty // Updated variable name
//           ? const Center(child: Text("No project recordings yet. Record something first!"))
//           : ListView.builder(
//         itemCount: _projectRecordings.length, // Updated variable name
//         itemBuilder: (context, index) {
//           final file = _projectRecordings[index]; // Updated variable name
//           final fileName = file.path.split("/").last;
//
//           return ListTile(
//             leading: Icon(
//               _currentlyPlaying == file.path ? Icons.pause_circle : Icons.play_circle,
//               color: _currentlyPlaying == file.path ? Colors.red : Colors.blue,
//             ),
//             // Trimming the file path name for cleaner display
//             title: Text(fileName.substring(0, fileName.lastIndexOf('.'))),
//             subtitle: Text("Saved: ${file.statSync().modified.toLocal().toString().split('.')[0]}"),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deleteRecording(file),
//             ),
//             onTap: () => _playRecording(file.path),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibin/services/auth_service.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<FileSystemEntity> _localRecordings = [];
  List<Map<String, String>> _supabaseRecordings = [];
  // Each map has {'url': signedUrl, 'path': storagePath}

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AuthServe _authServe = AuthServe(); // Local initialization
  String? _currentlyPlaying;

  @override
  void initState() {
    super.initState();
    _loadLocalRecordings();
    _loadSupabaseRecordings();

    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() => _currentlyPlaying = null);
    });
  }

  // Load local recordings
  Future<void> _loadLocalRecordings() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir
        .listSync()
        .where((file) => file.path.endsWith(".wav"))
        .toList()
      ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    setState(() => _localRecordings = files);
  }

  // Load Supabase recordings
  Future<void> _loadSupabaseRecordings() async {
    try {
      final list = await _authServe.listAudioFiles();
      // Returns List<Map<String,String>> with 'url' and 'path'
      setState(() => _supabaseRecordings = list);
    } catch (e) {
      debugPrint("❌ Error loading Supabase recordings: $e");
    }
  }

  // Play recording
  Future<void> _playRecording({String? localPath, String? networkUrl}) async {
    final pathToPlay = networkUrl ?? localPath;
    if (pathToPlay == null) return;

    if (_currentlyPlaying == pathToPlay) {
      await _audioPlayer.pause();
      setState(() => _currentlyPlaying = null);
    } else {
      await _audioPlayer.stop();
      if (networkUrl != null) {
        await _audioPlayer.play(UrlSource(networkUrl));
      } else {
        await _audioPlayer.play(DeviceFileSource(localPath!));
      }
      setState(() => _currentlyPlaying = pathToPlay);
    }
  }


  // Delete local recording
  Future<void> _deleteLocalRecording(FileSystemEntity file) async {
    if (_currentlyPlaying == file.path) {
      await _audioPlayer.stop();
      _currentlyPlaying = null;
    }
    await file.delete();
    _loadLocalRecordings();
  }

  // Delete Supabase recording
  Future<void> _deleteSupabaseRecording(Map<String, String> record) async {
    try {
      final storagePath = record['path']!;
      await _authServe.deleteAudio(storagePath);
      _loadSupabaseRecordings();
    } catch (e) {
      debugPrint("❌ Error deleting from Supabase: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Recordings 🎙")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Local recordings
            if (_localRecordings.isNotEmpty)
              ..._localRecordings.map((file) {
                final fileName = file.path.split("/").last;
                return ListTile(
                  leading: Icon(
                    _currentlyPlaying == file.path
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color:
                    _currentlyPlaying == file.path ? Colors.red : Colors.blue,
                  ),
                  title: Text(fileName.substring(0, fileName.lastIndexOf('.'))),
                  subtitle: Text(
                      "Saved: ${file.statSync().modified.toLocal().toString().split('.')[0]}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteLocalRecording(file),
                  ),
                  onTap: () => _playRecording(localPath: file.path),
                );
              }),

            if (_supabaseRecordings.isNotEmpty) const Divider(),

            // Supabase recordings
            ..._supabaseRecordings.map((record) {
              final uri = Uri.parse(record['url']!);
              final fileName = uri.pathSegments.last.split('.').first; // removes .wav
              return ListTile(
                leading: Icon(
                  _currentlyPlaying == record['url'] ? Icons.pause_circle : Icons.play_circle,
                  color: _currentlyPlaying == record['url'] ? Colors.red : Colors.green,
                ),
                title: Text(fileName),
                subtitle: const Text("Uploaded"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteSupabaseRecording(record),
                ),
                onTap: () => _playRecording(networkUrl: record['url']),
              );
            }),
          ],
        ),
      ),
    );
  }
}
