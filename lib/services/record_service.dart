// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:vibin/services/achievements.dart';
//
// class RecorderService {
//   static final RecorderService _instance = RecorderService._internal();
//   factory RecorderService() => _instance;
//   RecorderService._internal();
//
//   final AudioRecorder _audioRecorder = AudioRecorder();
//   bool _isRecording = false;
//   String? lastPath;
//
//   bool get isRecording => _isRecording;
//
//   Future<void> toggleRecording(
//       Function(String status) onStatusChanged, {
//         String? instrument, // new optional parameter
//       }) async {
//     if (_isRecording) {
//       // Stop recording
//       final path = await _audioRecorder.stop();
//       _isRecording = false;
//
//       if (path != null) {
//         lastPath = path;
//         await saveProject(path, instrument: instrument); // pass instrument here
//         await _incrementUserProjectCount();
//         onStatusChanged("Recording saved: ${path.split('/').last}");
//         HapticFeedback.mediumImpact();
//         achievementManager.trackAction("Recording");
//         //Future.microtask(() => achievementManager.trackAction("Recording"));
//       } else {
//         onStatusChanged("Recording failed to save.");
//       }
//     } else {
//       // Start recording
//       if (await _audioRecorder.hasPermission()) {
//         final dir = await getApplicationDocumentsDirectory();
//         final filePath = '${dir.path}/${instrument}_${DateTime.now().millisecondsSinceEpoch}.wav';
//
//         await _audioRecorder.start(
//           const RecordConfig(encoder: AudioEncoder.wav),
//           path: filePath,
//         );
//
//         _isRecording = true;
//         onStatusChanged("Recording...");
//         HapticFeedback.heavyImpact();
//       } else {
//         onStatusChanged("Microphone permission denied.");
//       }
//     }
//   }
//
//
//   Future<void> _incrementUserProjectCount() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return; // Not logged in, do nothing
//
//     final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
//
//     await FirebaseFirestore.instance.runTransaction((transaction) async {
//       final snapshot = await transaction.get(userRef);
//       final current = snapshot.exists ? (snapshot.data()?['projects'] ?? 0) : 0;
//       transaction.set(userRef, {'projects': current + 1}, SetOptions(merge: true));
//     });
//   }
//
//   Future<void> saveProject(String filePath, {String? instrument}) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final fileName = filePath.split('/').last;
//     final projectId = DateTime.now().millisecondsSinceEpoch.toString();
//     final projectRef = FirebaseFirestore.instance.collection('projects').doc(projectId);
//
//     await projectRef.set({
//       'userId': user.uid,
//       'userName': user.displayName ?? "Guest",
//       'fileName': fileName,
//       'instrument': instrument ?? "unknown", // store the instrument
//       'createdAt': FieldValue.serverTimestamp(),
//     });
//   }
//
//   Future<void> dispose() async {
//     _audioRecorder.dispose();
//   }
// }
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibin/services/achievements.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // REQUIRED IMPORT

class RecorderService {
  static final RecorderService _instance = RecorderService._internal();
  factory RecorderService() => _instance;
  RecorderService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? lastPath;

  // 1. Supabase Client Access
  // ⚠️ IMPORTANT: Replace 'Supabase.instance.client' if you access your client differently.
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'recordings'; // Ensure this matches your Supabase bucket name

  bool get isRecording => _isRecording;

  Future<void> toggleRecording(
      Function(String status) onStatusChanged, {
        String? instrument, // new optional parameter
      }) async {
    if (_isRecording) {
      // Stop recording
      final path = await _audioRecorder.stop();
      _isRecording = false;

      if (path != null) {
        lastPath = path;
        // The core work happens here: upload and save metadata
        await saveProject(path, instrument: instrument);
        await _incrementUserProjectCount();
        final instrumentName = instrument ?? "AudioTrack";
        onStatusChanged("Recording saved: ${instrumentName} track");
        HapticFeedback.mediumImpact();
        achievementManager.trackAction("Recording");
      } else {
        onStatusChanged("Recording failed to save.");
      }
    } else {
      // Start recording
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final instrumentName = instrument ?? "AudioTrack"; // Use default if null
        final filePath = '${dir.path}/${instrumentName}_${DateTime.now().millisecondsSinceEpoch}.wav';

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


  Future<void> _incrementUserProjectCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final current = snapshot.exists ? (snapshot.data()?['projects'] ?? 0) : 0;
        transaction.set(userRef, {'projects': current + 1}, SetOptions(merge: true));
      });
    } on FirebaseException catch (e) {
      print('[Firestore Error] Failed to increment project count: ${e.message}');
    }
  }

  // MODIFIED TO INCLUDE SUPABASE UPLOAD AND FOCUSED DEBUGGING
  Future<void> saveProject(String filePath, {String? instrument}) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      print('[Auth Check] Firebase user is null. Aborting upload.');
      return;
    }

    final file = File(filePath);
    final fileName = filePath.split('/').last;

    try {
      // 1️⃣ Get the Supabase UID from profiles table
      final profile = await _supabase
          .from('profiles')
          .select('supabase_uid')
          .eq('firebase_uid', firebaseUser.uid)
          .maybeSingle();

      if (profile == null) {
        print('[Supabase Mapping] No mapping found for Firebase UID: ${firebaseUser.uid}');
        print('>>> Make sure _linkSupabaseWithFirebase has been called.');
        return;
      }

      final supabaseUid = profile['supabase_uid'] as String;
      final storagePath = '$supabaseUid/$fileName';

      print('-----------------------------------------');
      print('Firebase UID: ${firebaseUser.uid}');
      print('Supabase UID: $supabaseUid');
      print('Storage Path: $storagePath');
      print('-----------------------------------------');

      // 2️⃣ Upload to Supabase Storage
      await _supabase.storage.from(_bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      // 3️⃣ Create a signed URL
      final downloadUrl = await _supabase.storage
          .from(_bucketName)
          .createSignedUrl(storagePath, 600);

      print('[Supabase] Upload successful. Signed URL: $downloadUrl');

      // 4️⃣ Save metadata in Firestore
      final projectId = DateTime.now().millisecondsSinceEpoch.toString();
      final projectRef = FirebaseFirestore.instance.collection('projects').doc(projectId);

      await projectRef.set({
        'userId': firebaseUser.uid,
        'userName': firebaseUser.displayName ?? "Guest",
        'fileName': fileName,
        'audioUrl': downloadUrl,
        'instrument': instrument ?? "unknown",
        'createdAt': FieldValue.serverTimestamp(),
      });







      File(filePath).delete();




      


      print('[Firestore] Metadata saved successfully for project $projectId');

    } on StorageException catch (e) {
      print('[Supabase Storage Error] Failed to upload audio: ${e.message}');
    } catch (e) {
      print('[RecorderService Error] $e');
    }
  }


  Future<void> dispose() async {
    _audioRecorder.dispose();
  }
}
