// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
//
// class AuthServe extends ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   User? _user;
//   User? get user => _user;
//
//   AuthServe() {
//     _user = _auth.currentUser;
//   }
//
//   /// Sign in with Google (7.x API)
//   Future<User?> signInWithGoogle() async {
//     try {
//       // Optional: initialize GoogleSignIn
//       await GoogleSignIn.instance.initialize();
//
//       final googleUser = await GoogleSignIn.instance.authenticate();
//       if (googleUser == null) return null; // user cancelled
//
//       final googleAuth = await googleUser.authentication;
//
//       // Only idToken is required for Firebase
//       final credential = GoogleAuthProvider.credential(
//         idToken: googleAuth.idToken,
//       );
//
//       UserCredential userCredential =
//       await _auth.signInWithCredential(credential);
//       _user = userCredential.user;
//
//       final docRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
//       final docSnapshot = await docRef.get();
//       if (!docSnapshot.exists) {
//         await docRef.set({
//           'name':_user!.displayName,
//           'email': _user!.email,
//           'isAdmin': false,
//           'projects':0,
//           'challenges':0,
//         });
//       }
//
//       notifyListeners();
//       return _user;
//     } catch (e) {
//       print('Google sign-in error: $e');
//       return null;
//     }
//   }
//
//   /// Sign in anonymously
//   Future<User?> signInAnonymously() async {
//     try {
//       UserCredential userCredential = await _auth.signInAnonymously();
//       _user = userCredential.user;
//
//       final docRef = FirebaseFirestore.instance.collection('users').doc(_user!.uid);
//       final docSnapshot = await docRef.get();
//       if (!docSnapshot.exists) {
//         await docRef.set({
//           'name':_user!.displayName,
//           'isAdmin': false,
//           'guest': true, // mark as guest
//           'projects':0,
//           'challenges':0,
//         });
//       }
//
//       notifyListeners();
//       return _user;
//     } catch (e) {
//       print('Anonymous sign-in error: $e');
//       return null;
//     }
//   }
//
//   // ---------------- Email/Password Sign-up ----------------
//   Future<User?> signUpWithEmail(String email, String password, String username) async {
//     try {
//       // Create user with email & password
//       final userCredential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Set the display name
//       await userCredential.user?.updateDisplayName(username);
//       await userCredential.user?.reload(); // refresh user data
//       _user = _auth.currentUser;
//
//       // --- Add Firestore document ---
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userCredential.user!.uid)
//           .set({
//         'name':_user!.displayName,
//         'email': email,
//         'isAdmin': false, // default for new users
//         'projects':0,
//         'challenges':0,
//       });
//
//       notifyListeners();
//       return _user;
//     } on FirebaseAuthException catch (e) {
//       print("Sign-up error: ${e.code} - ${e.message}");
//       return null;
//     }
//   }
//
//
//   // ---------------- Email/Password Sign-in ----------------
//   Future<User?> signInWithEmail(String email, String password) async {
//     try {
//       final userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       _user = userCredential.user;
//       notifyListeners();
//       return _user;
//     } on FirebaseAuthException catch (e) {
//       print("Sign-in error: ${e.code} - ${e.message}");
//       return null;
//     }
//   }
//
//   // ---------------- Password Reset ----------------
//   Future<void> sendPasswordResetEmail(String email) async {
//     if (email.isEmpty) {
//       throw Exception("Email cannot be empty.");
//     }
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//     } on FirebaseAuthException catch (e) {
//       throw Exception(e.message ?? "An unknown error occurred.");
//     } catch (e) {
//       throw Exception("An unknown error occurred.");
//     }
//   }
//
//   /// Sign out (works for both Google and anonymous)
//   Future<void> signOut() async {
//     try {
//       if (_user != null) {
//         if (_user!.isAnonymous) {
//           // Delete Firestore doc
//           await FirebaseFirestore.instance.collection('users').doc(_user!.uid).delete();
//           // Delete anonymous (guest) user
//           await _user!.delete();
//         } else if (_user!.providerData.any((p) => p.providerId == 'google.com')) {
//           // Sign out Google users
//           await GoogleSignIn.instance.signOut();
//         }
//
//         // Sign out from Firebase Auth
//         await _auth.signOut();
//         _user = null;
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Sign out error: $e');
//     }
//   }
// }

import 'dart:io';
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
      if (googleUser == null) {
        print("[AuthServe] Google sign-in cancelled by user");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      print("[AuthServe] Firebase Google user: ${_user!.uid}, email: ${_user!.email}");

      await _createFirestoreDoc(_user!);
      await _linkSupabaseWithFirebase(_user!);

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
      // Optional: skip Supabase for anonymous users
      // await _linkSupabaseWithFirebase(_user!);

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
      await _linkSupabaseWithFirebase(_user!);

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

      await _linkSupabaseWithFirebase(_user!);

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
      print("[AuthServe] Signing out Firebase and Supabase");
      await _auth.signOut();
      await _supabase.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      print('[AuthServe] Sign out error: $e');
    }
  }

  // ---------------- Firestore document creation ----------------
  Future<void> _createFirestoreDoc(User user, {String? username, String? email, bool isGuest = false}) async {
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

  // ---------------- Link Supabase with Firebase ----------------
  // ---------------- Link Supabase with Firebase (FIXED) ----------------
  Future<void> _linkSupabaseWithFirebase(User user) async {
    if (user.email == null) return;

    const defaultPassword = 'firebaseLinkedAccount123';
    final email = user.email!;

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: defaultPassword,
      );

      if (response.user != null) {
        // Insert mapping in your table
        await _supabase.from('profiles').insert({
          'firebase_uid': user.uid,
          'supabase_uid': response.user!.id,
          'email': email,
          'name': user.displayName,
        });
        print("[AuthServe] Supabase user created and linked.");
      } else {
        print("[AuthServe] Supabase sign-up response: ${response.session}");
      }
    } catch (e) {
      print("[AuthServe] Supabase linking error: $e");
    }
  }


  // ---------------- 🎵 Upload Audio to Supabase ----------------
  // ---------------- 🎵 Upload Audio to Supabase (CORRECTED PATH) ----------------
  Future<String?> uploadAudio(File file) async {
    if (_user == null) return null;

    final uid = _user!.uid;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_audio.wav';
    // The path must start with the UID for the RLS policy to work.
    final path = '$uid/$fileName';

    try {
      await _supabase.storage.from('recordings').upload(path, file);
      // The signed URL needs the full storage path
      final signedUrl = await _supabase.storage.from('recordings').createSignedUrl(path, 600);
      print("[AuthServe] Uploaded file: $path");
      return signedUrl;
    } catch (e) {
      print('[AuthServe] Supabase upload error: $e');
      return null;
    }
  }

  // ---------------- 🎵 List all user's audio files ----------------
  Future<List<Map<String, String>>> listAudioFiles() async {
    if (_user == null) return [];

    final firebaseUid = _user!.uid;

    try {
      // Get Supabase UID from profiles table
      final profile = await _supabase
          .from('profiles')
          .select('supabase_uid')
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();

      if (profile == null) {
        print('[AuthServe] No Supabase mapping found for Firebase UID: $firebaseUid');
        return [];
      }

      final supabaseUid = profile['supabase_uid'] as String;

      // List files in the user's folder
      final files = await _supabase.storage.from('recordings').list(path: supabaseUid);

      final List<Map<String, String>> recordings = [];

      for (var file in files) {
        final storagePath = '$supabaseUid/${file.name}';
        final signedUrl = await _supabase.storage
            .from('recordings')
            .createSignedUrl(storagePath, 3600);

        recordings.add({
          'url': signedUrl,     // For playback
          'path': storagePath,  // For deletion
        });
      }

      print("[AuthServe] Listed ${recordings.length} files for user $firebaseUid (Supabase UID: $supabaseUid)");
      return recordings;
    } catch (e) {
      print('[AuthServe] Supabase list error: $e');
      return [];
    }
  }


  // ---------------- 🎵 Delete audio from Supabase ----------------
  Future<void> deleteAudio(String filePathOrUrl) async {
    if (_user == null) return;

    final firebaseUid = _user!.uid;

    try {
      // Extract relative path if a full URL is passed
      String filePath = filePathOrUrl;
      if (filePath.contains('/object/public/recordings/')) {
        final parts = filePath.split('/object/public/recordings/');
        if (parts.length > 1) filePath = parts.last;
      }

      // Delete from Supabase storage
      await _supabase.storage.from('recordings').remove([filePath]);
      print("[AuthServe] ✅ Deleted file from Supabase: $filePath");

      final projectQuery = await FirebaseFirestore.instance
          .collection('projects')
          .where('userId', isEqualTo: firebaseUid)
          .where('fileName', isEqualTo: filePath.split('/').last)
          .get();
      for (var doc in projectQuery.docs) {
        await doc.reference.delete();
      }
      // --- Decrement Firestore projects counter ---
      final userRef = FirebaseFirestore.instance.collection('users').doc(firebaseUid);
      await userRef.update({
        'projects': FieldValue.increment(-1),
      });
      print("[AuthServe] ✅ Decremented Firestore projects for user: $firebaseUid");

    } catch (e) {
      print('[AuthServe] ❌ Supabase delete error: $e');
    }
  }
}

