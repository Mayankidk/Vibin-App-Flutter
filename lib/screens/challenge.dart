import 'package:flutter/material.dart';
import 'package:vibin/services/achievements.dart'; // your global manager

class ChallengesPage extends StatefulWidget {
  const ChallengesPage({super.key});

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> {
  @override
  void initState() {
    super.initState();
    // Listen to updates from the manager to refresh UI
    achievementManager.onUpdate = () => setState(() {});
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress(Achievement ach) {
    if (!ach.isTimeBased || ach.requiredDuration == null) return 0.0;
    final actionKey = ach.title.split(" ")[0]; // e.g., "Play"
    final spent = achievementManager.getTimeSpent(actionKey);
    return (spent / ach.requiredDuration!.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final achievements = achievementManager.achievements;
    final ongoing = achievements.where((a) => !a.isCompleted).toList();
    final completed = achievements.where((a) => a.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Challenges")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Ongoing Challenges
            if (ongoing.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Ongoing Challenges",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ongoing.length,
                        itemBuilder: (_, index) {
                          final ach = ongoing[index];
                          final progress = _getProgress(ach);
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.lock, color: Colors.grey),
                              title: Text(ach.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ach.description),
                                  if (ach.isTimeBased)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: LinearProgressIndicator(value: progress),
                                    ),
                                  if (ach.isTimeBased)
                                    Text(
                                      "Time spent: ${_formatTime(achievementManager.getTimeSpent(ach.title.split(" ")[0]))}",
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Completed Challenges
            if (completed.isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Completed Challenges",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: completed.length,
                        itemBuilder: (_, index) {
                          final ach = completed[index];
                          return Card(
                            child: ListTile(
                              leading: const Icon(Icons.emoji_events, color: Colors.orange),
                              title: Text(ach.title),
                              subtitle: Text(
                                "Unlocked at: ${ach.completedAt?.toLocal().toString().split('.')[0]}",
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
