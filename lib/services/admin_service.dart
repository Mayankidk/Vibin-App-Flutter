import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkIfAdmin() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false; // user not signed in

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && doc.data()?['isAdmin'] == true) {
      return true;
    }
    return false;
  } catch (e) {
    print("Error checking admin: $e");
    return false;
  }
}
