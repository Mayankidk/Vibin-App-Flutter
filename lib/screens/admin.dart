import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dashboardItems = [
      {
        "icon": Icons.people,
        "label": "User Management",
        "page": const UserManagementPage(),
      },
      {
        "icon": Icons.library_music,
        "label": "Content Management",
        "page": const ContentManagementPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----------------- Navigation Cards -----------------
            ...dashboardItems.map(
                  (item) => _DashboardCard(
                icon: item["icon"] as IconData,
                label: item["label"] as String,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => item["page"] as Widget),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),

            // ----------------- Stats -----------------
            Text("Analytics", style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            // Total Users
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _StatCard(
                  title: "Total Users",
                  value: "$count",
                  icon: Icons.people,
                );
              },
            ),
            //
            // SizedBox(height: 16),

            // Active Projects
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('projects').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                return _StatCard(
                  title: "Active Projects",
                  value: "$count",
                  icon: Icons.music_note,
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                int totalChallenges = 0;
                if (snapshot.hasData) {
                  totalChallenges = snapshot.data!.docs.fold<int>(0, (sum, doc) {
                    return sum + ((doc['challenges'] ?? 0) as num).toInt();
                  });
                }

                return _StatCard(
                  title: "Challenge Completed",
                  value: "$totalChallenges",
                  icon: Icons.check_circle,
                );
              },
            ),
            //const SizedBox(height: 10),

            // ----------------- Chart -----------------
            SizedBox(
              height: 300,
              child: Card(
                color: theme.colorScheme.secondaryContainer.withAlpha(
                  isDark ? 100 : 255,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection("projects").snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      // Count projects per instrument
                      final counts = {
                        'Guitar': 0,
                        'Piano': 0,
                        'Tabla': 0,
                      };

                      for (var doc in docs) {
                        final instrument = (doc.data() as Map<String, dynamic>)['instrument'] ?? 'unknown';
                        if (counts.containsKey(instrument)) {
                          counts[instrument] = counts[instrument]! + 1;
                        }
                      }

                      final total = counts.values.reduce((a, b) => a + b);
                      if (total == 0) {
                        return const Center(child: Text("No projects yet"));
                      }

                      final colors = [
                        Colors.redAccent,
                        Colors.blueAccent,
                        Colors.greenAccent,
                      ];

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: counts.entries.toList().asMap().entries.map((entry) {
                                final i = entry.key;
                                final instrument = entry.value.key;
                                final count = entry.value.value.toDouble();

                                return PieChartSectionData(
                                  color: colors[i % colors.length],
                                  value: count,
                                  title: '$instrument ${entry.value.value}', // name + count
                                  radius: 90,
                                  titleStyle: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          // Center total
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "$total",
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }
}

//
// ----------------- Reusable Dashboard Card -----------------
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: theme.colorScheme.secondaryContainer.withAlpha(
        isDark ? 100 : 255,
      ),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ----------------- Stat Card -----------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      color: theme.colorScheme.secondaryContainer.withAlpha(
        isDark ? 100 : 255,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 40, color: theme.colorScheme.primary),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: Text(
          value,
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

//
// ----------------- User Management Page -----------------
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection("users");

    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: usersRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user["name"] ?? "No name"),
                  subtitle: Text(user["email"] ?? "No email"),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          _showSnack(context, "Edit ${user["name"]}");
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showConfirmationDialog(
                            context,
                            "Confirm Deletion",
                            "Are you sure you want to delete ${user["name"]}?",
                          );
                          if (confirm) {
                            final userDoc = usersRef.doc(users[index].id);
                            final projectsQuery = FirebaseFirestore.instance
                                .collection('projects')
                                .where('userId', isEqualTo: users[index].id);

                            if (confirm) {
                              // 1. Delete all projects of the user
                              final querySnapshot = await projectsQuery.get();
                              final batch = FirebaseFirestore.instance.batch();

                              for (var doc in querySnapshot.docs) {
                                batch.delete(doc.reference);
                              }

                              // 2. Delete the user itself
                              batch.delete(userDoc);

                              // 3. Commit batch
                              await batch.commit();
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showSnack(context, "Add User tapped");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

//
// ----------------- Content Management Page -----------------
class ContentManagementPage extends StatelessWidget {
  const ContentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projectsRef = FirebaseFirestore.instance.collection("projects");

    return Scaffold(
      appBar: AppBar(title: const Text("Content Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: projectsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No projects found"));
          }

          final projects = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.music_note, color: Colors.purple),
                  title: Text(project["fileName"] ?? "Untitled"),
                  subtitle: Text("By ${project["userName"] ?? "Unknown"}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showConfirmationDialog(
                        context,
                        "Confirm Deletion",
                        "Are you sure you want to delete ${project["fileName"]}?",
                      );

                      if (!confirm) return;

                      try {
                        final firebaseUserId = project['userId'] as String;
                        final supabaseMap = await Supabase.instance.client
                            .from('profiles')
                            .select('supabase_uid')
                            .eq('firebase_uid', firebaseUserId)
                            .maybeSingle();
                        if (supabaseMap == null) {
                          print("No Supabase UID found for Firebase UID $firebaseUserId");
                        } else {
                          final supabaseUserId = supabaseMap['supabase_uid'] as String;
                          final fileName = project['fileName'] as String;
                          final filePath = "$supabaseUserId/$fileName";
                          final deletedFiles = await Supabase.instance.client
                              .storage
                              .from('recordings')
                              .remove([filePath]);
                          print("Deleted files: ${deletedFiles.map((f) => f.name).toList()}");
                        }
                        // 2️⃣ Delete Firestore project + update user
                        final batch = FirebaseFirestore.instance.batch();

                        final projectRef = projectsRef.doc(projects[index].id);
                        batch.delete(projectRef);

                        final userRef = FirebaseFirestore.instance.collection('users').doc(project['userId']);
                        batch.update(userRef, {
                          'projects': FieldValue.increment(-1),
                        });

                        await batch.commit();

                        // 3️⃣ Update local list / UI
                        projects.removeAt(index);
                        _showSnack(context, "Project deleted successfully!");
                      } catch (e) {
                        print("Error deleting project/audio: $e");
                        _showSnack(context, "Failed to delete project/audio");
                      }
                    },
                  ),

                ),
              );
            },
          );
        },
      ),
    );
  }
}

//
// ----------------- Helpers -----------------
// Future<int> _getCollectionCount(String collection) async {
//   final snapshot = await FirebaseFirestore.instance.collection(collection).get();
//   return snapshot.size;
// }
Future<bool> showConfirmationDialog(
    BuildContext context, String title, String content) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            "Delete",
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );

  return result ?? false; // Default to false if dialog is dismissed
}

void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
  );
}
