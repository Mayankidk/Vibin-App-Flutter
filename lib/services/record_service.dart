import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibin/services/achievements.dart';

class RecorderService {
  static final RecorderService _instance = RecorderService._internal();
  factory RecorderService() => _instance;
  RecorderService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? lastPath;
  int? _currentTimestamp; // <-- store timestamp

  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'recordings';

  bool get isRecording => _isRecording;

  Future<void> toggleRecording(
      Function(String status) onStatusChanged, {
        String? instrument,
      }) async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null) {
        lastPath = path;
        // Use the same timestamp consistently
        await _uploadAndSave(path, instrument: instrument, timestamp: _currentTimestamp!);
        //await _incrementUserProjectCount();
        final instrumentName = instrument ?? "AudioTrack";
        onStatusChanged("Recording saved: ${instrumentName} track");
        HapticFeedback.mediumImpact();
        achievementManager.trackAction("Recording");
      } else {
        onStatusChanged("Recording failed to save.");
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final instrumentName = instrument ?? "AudioTrack";

        // Generate timestamp once and store
        _currentTimestamp = DateTime.now().millisecondsSinceEpoch;

        final filePath =
            '${dir.path}/${instrumentName}_$_currentTimestamp.wav';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: filePath,
        );

        _isRecording = true;
        onStatusChanged("Recording...");
        HapticFeedback.heavyImpact();
      } else {
        onStatusChanged("Microphone permission denied.");
      }
    }
  }
  // Future<void> _incrementUserProjectCount() async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return;
  //
  //   final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  //
  //   try {
  //     await FirebaseFirestore.instance.runTransaction((transaction) async {
  //       final snapshot = await transaction.get(userRef);
  //       final current = snapshot.exists ? (snapshot.data()?['projects'] ?? 0) : 0;
  //       transaction.set(userRef, {'projects': current + 1}, SetOptions(merge: true));
  //     });
  //   } catch (e) {
  //     print('[Firestore Error] Failed to increment project count: $e');
  //   }
  // }

  Future<void> _uploadAndSave(String filePath, {String? instrument, required int timestamp}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final file = File(filePath);
    final fileName = filePath.split('/').last;
    final storagePath = '${firebaseUser.uid}/$fileName';

    try {
      await _supabase.storage.from(_bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(storagePath);

      final projectId = timestamp.toString(); // use consistent timestamp for projectId
      final projectRef = FirebaseFirestore.instance.collection('projects').doc(projectId);

      await projectRef.set({
        'userId': firebaseUser.uid,
        'userName': firebaseUser.displayName ?? "Guest",
        'fileName': fileName,
        'audioUrl': publicUrl,
        'instrument': instrument ?? "unknown",
        'createdAt': FieldValue.serverTimestamp(),
      });

      final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
      try {
        await userRef.update({
          'projects': FieldValue.increment(1),
        });
      } catch (e) {
        print('[Firestore Error] Failed to increment project count: $e');
      }

      print('[RecorderService] Uploaded & saved project $projectId');

      try {
        await file.delete();
      } catch (e) {
        print('[File Deletion Error] $e');
      }
    } catch (e) {
      print('[Supabase Upload Error] $e');
    }
  }

  Future<void> dispose() async {
    _audioRecorder.dispose();
  }
}
