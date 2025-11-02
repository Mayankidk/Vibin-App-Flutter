import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Appearance ----------
          Text(
            "Appearance",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // instead of just a switch, use radio options
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: themeProvider.themeMode,
                  title: const Text("System Default"),
                  secondary: const Icon(Icons.settings),
                  onChanged: (mode) => themeProvider.setTheme(mode!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: themeProvider.themeMode,
                  title: const Text("Light"),
                  secondary: const Icon(Icons.light_mode),
                  onChanged: (mode) => themeProvider.setTheme(mode!),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: themeProvider.themeMode,
                  title: const Text("Dark"),
                  secondary: const Icon(Icons.dark_mode),
                  onChanged: (mode) => themeProvider.setTheme(mode!),
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text("Theme Color"),
                  subtitle: const Text("Purple"),
                  onTap: () {
                    // open theme picker (future feature)
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---------- Notifications ----------
          Text(
            "Notifications",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications),
                  title: const Text("Push Notifications"),
                  value: true,
                  onChanged: (value) {
                    // toggle notifications
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.music_note),
                  title: const Text("Sound Effects"),
                  value: true,
                  onChanged: (value) {
                    // toggle sounds
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ---------- Language ----------
          Text(
            "Language",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("App Language"),
              subtitle: const Text("English"),
              onTap: () {
                // open language selector
              },
            ),
          ),
        ],
      ),
    );
  }
}
