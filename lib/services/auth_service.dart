import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthServe extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  User? get user => _user;

  AuthServe() {
    _user = _auth.currentUser;
    print("[AuthServe] Initialized with Firebase user: ${_user?.uid}");
  }

  // ---------------- Google Sign-in ----------------
  Future<User?> signInWithGoogle() async {
    try {
      print("[AuthServe] Google sign-in started");
      await GoogleSignIn.instance.initialize();
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      print("[AuthServe] Firebase Google user: ${_user!.uid}, email: ${_user!.email}");
      await _createFirestoreDoc(_user!);

      notifyListeners();
      return _user;
    } catch (e) {
      print('[AuthServe] Google sign-in error: $e');
      return null;
    }
  }

  // ---------------- Anonymous Sign-in ----------------
  Future<User?> signInAnonymously() async {
    try {
      print("[AuthServe] Anonymous sign-in started");
      final userCredential = await _auth.signInAnonymously();
      _user = userCredential.user;

      print("[AuthServe] Firebase anonymous user: ${_user!.uid}");
      await _createFirestoreDoc(_user!, isGuest: true);

      notifyListeners();
      return _user;
    } catch (e) {
      print('[AuthServe] Anonymous sign-in error: $e');
      return null;
    }
  }

  // ---------------- Email Sign-up ----------------
  Future<User?> signUpWithEmail(String email, String password, String username) async {
    try {
      print("[AuthServe] Email sign-up started: $email");
      final userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user?.updateDisplayName(username);
      await userCredential.user?.reload();
      _user = _auth.currentUser;

      print("[AuthServe] Firebase Email user: ${_user!.uid}, email: ${_user!.email}");
      await _createFirestoreDoc(_user!, username: username, email: email);

      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print("[AuthServe] Sign-up error: ${e.code} - ${e.message}");
      return null;
    }
  }

  // ---------------- Email Sign-in ----------------
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      print("[AuthServe] Email sign-in started: $email");
      final userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = userCredential.user;

      print("[AuthServe] Firebase Email user signed in: ${_user!.uid}, email: ${_user!.email}");
      notifyListeners();
      return _user;
    } on FirebaseAuthException catch (e) {
      print("[AuthServe] Sign-in error: ${e.code} - ${e.message}");
      return null;
    }
  }

  // ---------------- Password Reset ----------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      print("[AuthServe] Sending password reset email to $email");
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print("[AuthServe] Password reset error: $e");
      rethrow;
    }
  }

  // ---------------- Sign Out ----------------
  Future<void> signOut() async {
    try {
      print("[AuthServe] Signing out Firebase");
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('[AuthServe] Sign out error: $e');
    }
  }

  // ---------------- Firestore document creation ----------------
  Future<void> _createFirestoreDoc(User user,
      {String? username, String? email, bool isGuest = false}) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      print("[AuthServe] Creating Firestore document for user ${user.uid}");
      await docRef.set({
        'name': username ?? user.displayName ?? (isGuest ? 'Guest' : 'Unknown'),
        'email': email ?? user.email,
        'isAdmin': false,
        'guest': isGuest,
        'projects': 0,
        'challenges': 0,
      });
    } else {
      print("[AuthServe] Firestore document already exists for user ${user.uid}");
    }
  }

  // ---------------- 🎵 Upload Audio ----------------
  // Future<String?> uploadAudio(File file, {String? userFolder}) async {
  //   if (_user == null) return null;
  //
  //   final bucket = _supabase.storage.from('recordings');
  //   final folder = userFolder ?? _user!.uid; // optional folder per user
  //   final fileName = '${DateTime.now().millisecondsSinceEpoch}_audio.wav';
  //   final path = '$folder/$fileName';
  //
  //   try {
  //     await bucket.upload(path, file);
  //     final publicUrl = bucket.getPublicUrl(path);
  //     print("[AuthServe] Uploaded file to: $path → $publicUrl");
  //     return publicUrl; // ready for playback
  //   } catch (e) {
  //     print('[AuthServe] Supabase upload error: $e');
  //     return null;
  //   }
  // }

  // ---------------- 🎵 List Audio Files ----------------
  Future<List<Map<String, String>>> listAudioFiles({String? userFolder}) async {
    if (_user == null) return [];

    final bucket = _supabase.storage.from('recordings');
    final folder = userFolder ?? _user!.uid; // optional folder per user

    try {
      final files = await bucket.list(path: folder);
      final List<Map<String, String>> recordings = [];

      for (var file in files) {
        if (file.name.startsWith('.')) continue;

        final storagePath = '$folder/${file.name}';
        final url = bucket.getPublicUrl(storagePath);

        recordings.add({
          'path': storagePath,
          'url': url,
        });
      }
      recordings.sort((a, b) => b['path']!.split('_').last.compareTo(a['path']!.split('_').last));
      print("[AuthServe] Listed ${recordings.length} files for folder: $folder");
      return recordings;
    } catch (e) {
      print('[AuthServe] Supabase list error: $e');
      return [];
    }
  }


  // ---------------- 🎵 Delete Audio ----------------
  Future<void> deleteAudio(String path) async {
    if (_user == null) return;
    final userRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
    final parts = path.split('_').last;
    final projectId = parts.split('.').first;
    final projectRef = FirebaseFirestore.instance.collection("projects").doc(projectId);
    await projectRef.delete();
    print("[Delete] Removed Firestore project $projectId");
    try {
      final bucket = _supabase.storage.from('recordings');
      await bucket.remove([path]);
      print("[AuthServe] Deleted file from Supabase: $path");
      try {
        await userRef.update({
          'projects': FieldValue.increment(-1),
        });
      } catch (e) {
        print('[Firestore Error] Failed to increment project count: $e');
      }
    } catch (e) {
      print('[AuthServe] Supabase delete error: $e');
    }
  }
}
