import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

/// -------------------- Achievement Model --------------------
class Achievement {
  final String title;
  final String description;
  final bool isTimeBased;
  final Duration? requiredDuration;
  final bool requiresAction;
  bool isCompleted;
  DateTime? completedAt;

  Achievement({
    required this.title,
    required this.description,
    this.isTimeBased = false,
    this.requiredDuration,
    this.requiresAction = false,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  void loadFromMap(Map<String, dynamic>? map) {
    if (map == null) return;
    isCompleted = map['isCompleted'] ?? false;
    completedAt = map['completedAt'] != null
        ? DateTime.tryParse(map['completedAt'])
        : null;
  }
}

/// -------------------- Passive Achievement Manager --------------------
class AchievementManager {
  final Box _box = Hive.box('achievements');
  final Map<String, int> _timeSpent = {}; // seconds spent per action
  final List<Achievement> achievements = [
    Achievement(title: "Play Piano", description: "Play piano at least once", requiresAction: true),
    Achievement(title: "Play Guitar", description: "Play guitar at least once", requiresAction: true),
    Achievement(title: "Guitar Practice", description: "Play guitar for 15 min", isTimeBased: true, requiredDuration: const Duration(minutes: 15)),
    Achievement(title: "First Recording", description: "Save your first recording", requiresAction: true),
  ];

  Timer? _timer;
  VoidCallback? onUpdate;

  AchievementManager({this.onUpdate}) {
    _loadFromHive();
    _startTimer();
  }

  // 🔁 Load data from Hive on startup
  void _loadFromHive() {
    for (var ach in achievements) {
      final stored = _box.get('ach_${ach.title}');
      if (stored != null && stored is Map) {
        ach.loadFromMap(Map<String, dynamic>.from(stored)); // ✅ cast to correct type
      }
    }

    final storedTimes = _box.get('timeSpent', defaultValue: <String, int>{});
    if (storedTimes is Map) {
      _timeSpent.addAll(Map<String, int>.from(storedTimes));
    }
  }

  // 💾 Save current time + achievement progress
  void _saveToHive() {
    for (var ach in achievements) {
      _box.put('ach_${ach.title}', ach.toMap());
    }
    _box.put('timeSpent', _timeSpent);
  }

  int getTimeSpent(String action) => _timeSpent[action] ?? 0;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _checkTimeAchievements();
    });
  }

  void _checkTimeAchievements() {
    _timeSpent.forEach((action, seconds) {
      for (var ach in achievements.where((a) => a.isTimeBased && !a.isCompleted && a.title.toLowerCase().contains(action.toLowerCase()))) {
        if (Duration(seconds: seconds) >= ach.requiredDuration!) {
          _completeAchievement(ach);
        }
      }
    });
  }

  /// Call this when user performs an action (e.g., plays piano/guitar)
  Future<void> trackAction(String action) async {
    _timeSpent[action] = (_timeSpent[action] ?? 0) + 1;

    // Unlock achievements for actions
    for (var ach in achievements.where((a) => a.requiresAction && !a.isCompleted && a.title.toLowerCase().contains(action.toLowerCase()))) {
      await _completeAchievement(ach);
    }

    _saveToHive(); // 💾 Save after update
    onUpdate?.call();
  }

  Future<void> _completeAchievement(Achievement ach) async {
    if (ach.isCompleted) return;

    ach.isCompleted = true;
    ach.completedAt = DateTime.now();
    debugPrint("Achievement unlocked: ${ach.title}");

    await _incrementChallenges();
    _saveToHive(); // 💾 Save after completion
    onUpdate?.call();
  }

  Future<void> _incrementChallenges() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final current = snapshot.exists ? (snapshot.data()?['challenges'] ?? 0) : 0;
      transaction.set(userRef, {'challenges': current + 1}, SetOptions(merge: true));
    });
  }

  void dispose() {
    _timer?.cancel();
    _saveToHive(); // save before closing
  }

  Achievement? getAchievement(String title) {
    try {
      return achievements.firstWhere((a) => a.title == title);
    } catch (e) {
      return null;
    }
  }
}

final achievementManager = AchievementManager();
