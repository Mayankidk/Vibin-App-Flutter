import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final dashboardItems = [
      {
        "icon": Icons.people,
        "label": "User Management",
        "page": const UserManagementPage(),
      },
      {
        "icon": Icons.library_music,
        "label": "Content",
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
            const SizedBox(height: 20),

            // ----------------- Stats -----------------
            Text("Analytics", style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _StatCard(title: "Total Users", value: "1200", icon: Icons.people),
            _StatCard(
              title: "Active Projects",
              value: "350",
              icon: Icons.music_note,
            ),
            const SizedBox(height: 20),

            // ----------------- Chart -----------------
            SizedBox(
              height: 300,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(show: true),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 1),
                            FlSpot(1, 3),
                            FlSpot(2, 2),
                            FlSpot(3, 5),
                            FlSpot(4, 4),
                          ],
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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

    return Card(
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
    return Card(
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

// ----------------- Placeholder Pages -----------------
//
// ----------------- User Management -----------------
class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final users = [
      {"name": "Alice", "email": "alice@email.com"},
      {"name": "Bob", "email": "bob@email.com"},
      {"name": "Charlie", "email": "charlie@email.com"},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(user["name"]!),
              subtitle: Text(user["email"]!),
              trailing: Wrap(
                spacing: 8,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: theme.colorScheme.tertiary),
                    onPressed: () {
                      _showSnack(context, "Edit ${user["name"]}");
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: () {
                      _showSnack(context, "Deleted ${user["name"]}");
                    },
                  ),
                ],
              ),
            ),
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

class ContentManagementPage extends StatelessWidget {
  const ContentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final projects = [
      {"title": "Chill Beats", "owner": "Alice", "time": "2 days ago"},
      {"title": "Rock Jam", "owner": "Bob", "time": "5 days ago"},
      {"title": "Lo-Fi Vibes", "owner": "Charlie", "time": "1 week ago"},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("Content Management")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.music_note, color: Colors.purple),
              title: Text(project["title"]!),
              subtitle: Text("By ${project["owner"]} • ${project["time"]}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _showSnack(context, "Removed ${project["title"]}");
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

void _showSnack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
  );
}
