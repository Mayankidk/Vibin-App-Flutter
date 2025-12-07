// import 'package:firebase_auth/firebase_auth.dart' as fa; // Prefix for Firebase Auth
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// /// A service to synchronize the user session between Firebase and Supabase.
// class AuthSyncService {
//   // Supabase.instance.client.auth returns the GoTrueClient instance.
//   final GoTrueClient _goTrue = Supabase.instance.client.auth;
//
//   /// Exchanges the Firebase ID token for a Supabase session using the 'firebase' provider.
//   /// This ensures the Supabase auth.uid() matches the Firebase UID.
//   // Future<void> synchronizeSupabaseUser(fa.User firebaseUser) async { // Use fa.User
//   //   try {
//   //     // 1. Get the Firebase ID Token (JWT)
//   //     final idToken = await firebaseUser.getIdToken();
//   //
//   //     if (idToken == null) {
//   //       print('[AuthSync] Error: Firebase ID Token is null.');
//   //       return;
//   //     }
//   //
//   //     // 2. Sign in to Supabase using the ID Token.
//   //     // ⚠️ WORKAROUND: The strict type checking in your current Supabase SDK requires
//   //     // an OAuthProvider enum, even though the custom 'firebase' provider is a string.
//   //     // We use a placeholder enum (e.g., google) to satisfy the compiler, trusting the
//   //     // Supabase server to use the provider associated with the ID token payload.
//   //     final response = await _goTrue.signInWithIdToken(
//   //       provider: OAuthProvider.google, // Placeholder to fix compilation
//   //       idToken: idToken,
//   //     );
//   //
//   //     // Check the returned Supabase user (User) against the Firebase user (fa.User)
//   //     if (response.user != null && response.user!.id == firebaseUser.uid) {
//   //       print('🟢 [AuthSync] Synchronization successful. Supabase UID now matches Firebase UID: ${response.user!.id}');
//   //     } else {
//   //       print('🔴 [AuthSync] WARNING: Supabase sign-in succeeded, but UIDs still don\'t match.');
//   //       print('Supabase ID: ${response.user?.id}');
//   //       print('Firebase ID: ${firebaseUser.uid}');
//   //     }
//   //   } catch (e) {
//   //     print('🔴 [AuthSync] Fatal error during token exchange: $e');
//   //   }
//   // }
//   Future<void> synchronizeSupabaseUser(fa.User firebaseUser) async {
//     try {
//       final idToken = await firebaseUser.getIdToken();
//       if (idToken == null) throw Exception("Firebase ID Token is null");
//
//       final response = await Supabase.instance.client.auth.signInWithIdToken(
//         provider: 'firebase' as dynamic, // bypass enum type
//         idToken: idToken,
//       );
//
//       if (response.session != null) {
//         print("Supabase session established.");
//       } else {
//         print("Supabase session failed.");
//       }
//     } catch (e) {
//       print("Error syncing Supabase: $e");
//     }
//   }
//
//   /// Call this when the app starts to ensure the session is fresh.
//   Future<void> reauthenticateIfNecessary() async {
//     final firebaseUser = fa.FirebaseAuth.instance.currentUser; // Use fa.FirebaseAuth
//     if (firebaseUser != null && Supabase.instance.client.auth.currentUser?.id != firebaseUser.uid) {
//       print('[AuthSync] Reauthenticating Supabase session...');
//       await synchronizeSupabaseUser(firebaseUser);
//     }
//   }
// }
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthSyncService {
  final GoTrueClient _goTrue = Supabase.instance.client.auth;

  Future<void> synchronizeSupabaseUser(fa.User firebaseUser) async {
    try {
      final String? idToken = await firebaseUser.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw Exception("Firebase ID Token is null or empty");
      }

      final response = await _goTrue.signInWithIdToken(
        provider: 'firebase' as dynamic,
        idToken: idToken!,
      );

      final supabaseUser = response.user;
      if (response.session == null || supabaseUser == null) {
        print("🔴 Supabase session failed.");
        return;
      }

      print("🟢 Supabase session established. Supabase UID: ${supabaseUser.id}");

      // Map Firebase UID in metadata
      final currentMeta = supabaseUser.userMetadata;
      final existing = currentMeta?['firebase_uid'];
      if (existing != firebaseUser.uid) {
        await _goTrue.updateUser(
          UserAttributes(
            data: {'firebase_uid': firebaseUser.uid},
          ),
        );
        print("✅ Firebase UID mapped to Supabase metadata.");
      }
    } catch (e) {
      print("🔴 Error syncing Supabase: $e");
    }
  }

  Future<void> reauthenticateIfNecessary() async {
    final firebaseUser = fa.FirebaseAuth.instance.currentUser;
    final supabaseUser = Supabase.instance.client.auth.currentUser;

    if (firebaseUser != null &&
        (supabaseUser == null ||
            supabaseUser.userMetadata?['firebase_uid'] != firebaseUser.uid)) {
      print('[AuthSync] Reauthenticating Supabase session...');
      await synchronizeSupabaseUser(firebaseUser);
    }
  }
}

