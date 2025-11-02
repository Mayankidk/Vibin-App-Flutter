import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:vibin/services/auth_service.dart';
// No need to import image_picker or firebase_storage anymore
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

//import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 16.0,
    ).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGradient = isDark
        ? [const Color(0xFF2c0066), const Color(0xFF1A003C)]
        : [const Color(0xFF7912ff), const Color(0xFFe9d9ff)];
    final neonColor = theme.colorScheme.secondary;

    // Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    final String? userPhotoUrl = user?.photoURL;
    final String userEmail = user?.email?.isEmpty ?? true? "guest@example.com": user!.email!;
    final String userName = user?.displayName?.isEmpty ?? true ? "Guest" : user!.displayName!;


    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          : null, // Handle the case where the user is not signed in
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle cases where the stream is null (user not logged in) or data is missing
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found.')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;

        Future<void> _showEditNameDialog() async {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            return; // Exit if the user is not authenticated
          }
          final nameController = TextEditingController(text: userData['name'] ?? '');

          return showDialog<void>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Edit Username'),
                content: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Enter your new name"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () async {
                      if (nameController.text.isNotEmpty) {
                        try {
                          // Action 1: Update the Firebase Auth user profile
                          await user.updateDisplayName(nameController.text.trim());

                          // Action 2: Update the Cloud Firestore document
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({'name': nameController.text.trim()});

                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        } on FirebaseAuthException catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update name: ${e.message}')),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to update name: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              );
            },
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text("Profile", style: theme.textTheme.headlineSmall),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                // HEADER
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (_, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: neonColor.withValues(alpha: 0.5),
                                      blurRadius: _pulseAnimation.value,
                                      spreadRadius: _pulseAnimation.value / 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: CircleAvatar(
                              radius: 60,
                              // Use the photoURL from Firebase Auth
                              backgroundImage: userPhotoUrl!=null?
                              NetworkImage(userPhotoUrl) : AssetImage("assets/images/default_avatar.jpg"),
                            ),
                          ),
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.indigoAccent,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                // Show a simple message instead of uploading
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profile picture is linked to your Google Account.',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // STATS ROW
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          color: Color.lerp(
                            Colors.blue,
                            isDark ? Colors.black : Colors.white,
                            0.65,
                          )!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Text(
                                  '${userData['projects'] ?? 0}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Projects',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Colors.green.shade500,
                              width: 2,
                            ),
                          ),
                          color: Color.lerp(
                            Colors.green.shade500,
                            isDark ? Colors.black : Colors.white,
                            0.65,
                          )!,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                Text(
                                  '${userData['challenges'] ?? 0}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Challenges',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // INFO CARD
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? Colors.white54 : Colors.black45,
                      width: 2,
                    ),
                  ),
                  color: theme.colorScheme.surfaceContainer,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding:
                        const EdgeInsets.only(left: 16, right: 8),
                        leading: const Icon(Icons.person, size: 26),
                        title: const Text(
                          'Username',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userName,
                            style: const TextStyle(fontSize: 14)),
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: _showEditNameDialog,
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ),
                      const Divider(height: 0, thickness: 1),
                      ListTile(
                        contentPadding:
                        const EdgeInsets.only(left: 16, right: 8),
                        leading: const Icon(Icons.email, size: 26),
                        title: const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(userEmail,
                            style: const TextStyle(fontSize: 14)),
                        trailing: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email cannot be edited.'),
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Icon(Icons.edit),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ACTIONS CARD
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                  color: Color.lerp(
                    Colors.redAccent.withAlpha(25),
                    theme.colorScheme.surface,
                    0.88,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'Log Out',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        onTap: () {
                          _showConfirmationDialog(
                            title: 'Log Out',
                            content: 'Are you sure you want to log out?',
                            onConfirm: () async {
                              await AuthServe().signOut();
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomePage()), (route) => false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Logged out successfully')),
                              );
                            },
                          );
                        },
                      ),
                      Divider(
                        color: Colors.redAccent.withAlpha(50),
                        thickness: 0.6,
                        height: 0,
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          'Delete Account',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                        onTap: () {
                          _showConfirmationDialog(
                            title: 'Delete Account',
                            content: 'Are you sure you want to delete your account? This action cannot be undone.',
                            onConfirm: () async {
                              try {
                                await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).delete();
                                await FirebaseAuth.instance.currentUser?.delete();
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomePage()), (route) => false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Account deleted successfully')),
                                );
                              } on FirebaseAuthException catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Failed to delete account: ${e.message}')),
                                  );
                                }
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
