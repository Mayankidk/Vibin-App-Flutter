// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:provider/provider.dart';
// import 'package:vibin/theme_provider.dart';
// import 'package:vibin/notification_service.dart';
//
// class SettingsPage extends StatefulWidget {
//   const SettingsPage({super.key});
//
//   @override
//   State<SettingsPage> createState() => _SettingsPageState();
// }
//
// class _SettingsPageState extends State<SettingsPage> {
//   bool _notificationsEnabled = false;
//   bool _soundEnabled = true;
//
//   // ---------- THEME COLOR PICKER ----------
//   void _openColorPicker(BuildContext context, ThemeProvider themeProvider) {
//     Color tempColor = themeProvider.seedColor;
//     final hexController = TextEditingController(
//       text: '#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}',
//     );
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             top: 20,
//             left: 20,
//             right: 20,
//           ),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "Pick a Theme Color",
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 10),
//                 ListTile(
//                   leading: const Icon(Icons.refresh),
//                   title: const Text("App Default"),
//                   subtitle: const Text("Reset to original purple"),
//                   onTap: () {
//                     themeProvider.resetToDefaultSeed();
//                     Navigator.pop(context);
//                   },
//                 ),
//                 ColorPicker(
//                   pickerColor: tempColor,
//                   onColorChanged: (color) {
//                     tempColor = color;
//                     hexController.text =
//                     '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
//                   },
//                   pickerAreaBorderRadius: BorderRadius.circular(16),
//                   pickerAreaHeightPercent: 0.8,
//                   enableAlpha: false,
//                   displayThumbColor: true,
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: hexController,
//                   decoration: const InputDecoration(
//                     labelText: "Hex Code",
//                     prefixIcon: Icon(Icons.colorize),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(12)),
//                     ),
//                   ),
//                   onSubmitted: (value) {
//                     try {
//                       final hex = value.replaceAll("#", "");
//                       if (hex.length == 6) {
//                         tempColor = Color(int.parse("0xFF$hex"));
//                       }
//                     } catch (_) {}
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     themeProvider.setSeedColor(tempColor);
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Apply"),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Settings")),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // ---------- Appearance ----------
//           Text(
//             "Appearance",
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: theme.colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 RadioListTile<ThemeMode>(
//                   value: ThemeMode.system,
//                   groupValue: themeProvider.themeMode,
//                   title: const Text("System Default"),
//                   secondary: const Icon(Icons.settings),
//                   onChanged: (mode) => themeProvider.setTheme(mode!),
//                 ),
//                 RadioListTile<ThemeMode>(
//                   value: ThemeMode.light,
//                   groupValue: themeProvider.themeMode,
//                   title: const Text("Light"),
//                   secondary: const Icon(Icons.light_mode),
//                   onChanged: (mode) => themeProvider.setTheme(mode!),
//                 ),
//                 RadioListTile<ThemeMode>(
//                   value: ThemeMode.dark,
//                   groupValue: themeProvider.themeMode,
//                   title: const Text("Dark"),
//                   secondary: const Icon(Icons.dark_mode),
//                   onChanged: (mode) => themeProvider.setTheme(mode!),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.color_lens),
//                   title: const Text("Theme Color"),
//                   subtitle: Text(
//                     themeProvider.useDefaultSeed
//                         ? "App Default"
//                         : "#${themeProvider.seedColor.value.toRadixString(16).substring(2).toUpperCase()}",
//                   ),
//                   onTap: () => _openColorPicker(context, themeProvider),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // ---------- Notifications ----------
//           Text(
//             "Notifications",
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: theme.colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Column(
//               children: [
//                 SwitchListTile(
//                   secondary: const Icon(Icons.notifications),
//                   title: const Text("Push Notifications"),
//                   subtitle: Text(
//                     _notificationsEnabled
//                         ? "You’ll receive reminders 🎶"
//                         : "Currently turned off",
//                   ),
//                   value: _notificationsEnabled,
//                   onChanged: (value) async {
//                     setState(() => _notificationsEnabled = value);
//
//                     if (value) {
//                       await NotificationService.init(); // ensure permission
//                       await NotificationService.showNotification(
//                         title: "Vibin’ Notifications",
//                         body: "Notifications are now enabled ✅",
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Notifications disabled ❌"),
//                         ),
//                       );
//                     }
//                   },
//                 ),
//                 SwitchListTile(
//                   secondary: const Icon(Icons.music_note),
//                   title: const Text("Sound Effects"),
//                   value: _soundEnabled,
//                   onChanged: (value) {
//                     setState(() => _soundEnabled = value);
//                   },
//                 ),
//                 Padding(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: ElevatedButton.icon(
//                     icon: const Icon(Icons.schedule),
//                     label: const Text("Test Scheduled Notification"),
//                     onPressed: () async {
//                       await NotificationService.showScheduledNotification(
//                         title: "Vibin Reminder 🎵",
//                         body: "This is a scheduled test notification!",
//                         seconds: 5,
//                       );
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content:
//                           Text("Notification scheduled in 5 seconds"),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 24),
//
//           // ---------- Language ----------
//           Text(
//             "Language",
//             style: theme.textTheme.titleMedium?.copyWith(
//               color: theme.colorScheme.primary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: ListTile(
//               leading: const Icon(Icons.language),
//               title: const Text("App Language"),
//               subtitle: const Text("English"),
//               onTap: () {
//                 // TODO: implement language selector
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:vibin/theme_provider.dart';
import 'package:vibin/notification_service.dart';
import 'package:hive/hive.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = false;
  bool _soundEnabled = true;
  late Box _settingsBox;
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settingsBox = await Hive.openBox('settings');
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    // Load ThemeProvider values from Hive
    await _themeProvider.loadFromHive(_settingsBox);

    // Load other settings
    setState(() {
      _notificationsEnabled =
          _settingsBox.get('notifications', defaultValue: false);
      _soundEnabled = _settingsBox.get('sound', defaultValue: true);
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> _saveTheme() async {
    await _themeProvider.saveToHive(_settingsBox);
  }

  void _openColorPicker(BuildContext context) {
    Color tempColor = _themeProvider.seedColor;
    final hexController = TextEditingController(
      text: '#${tempColor.value.toRadixString(16).substring(2).toUpperCase()}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pick a Theme Color",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text("App Default"),
                  subtitle: const Text("Reset to original purple"),
                  onTap: () {
                    _themeProvider.resetToDefaultSeed();
                    _saveTheme();
                    Navigator.pop(context);
                  },
                ),
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (color) {
                    tempColor = color;
                    hexController.text =
                    '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
                  },
                  pickerAreaBorderRadius: BorderRadius.circular(16),
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: false,
                  displayThumbColor: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: hexController,
                  decoration: const InputDecoration(
                    labelText: "Hex Code",
                    prefixIcon: Icon(Icons.colorize),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  onSubmitted: (value) {
                    try {
                      final hex = value.replaceAll("#", "");
                      if (hex.length == 6) {
                        tempColor = Color(int.parse("0xFF$hex"));
                      }
                    } catch (_) {}
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _themeProvider.setSeedColor(tempColor);
                    _saveTheme();
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---------- Appearance ----------
          Text(
            "Appearance",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeProvider.themeMode,
                  title: const Text("System Default"),
                  secondary: const Icon(Icons.settings),
                  onChanged: (mode) {
                    _themeProvider.setTheme(mode!);
                    _saveTheme();
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeProvider.themeMode,
                  title: const Text("Light"),
                  secondary: const Icon(Icons.light_mode),
                  onChanged: (mode) {
                    _themeProvider.setTheme(mode!);
                    _saveTheme();
                  },
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeProvider.themeMode,
                  title: const Text("Dark"),
                  secondary: const Icon(Icons.dark_mode),
                  onChanged: (mode) {
                    _themeProvider.setTheme(mode!);
                    _saveTheme();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text("Theme Color"),
                  subtitle: Text(
                    _themeProvider.useDefaultSeed
                        ? "App Default"
                        : "#${_themeProvider.seedColor.value.toRadixString(16).substring(2).toUpperCase()}",
                  ),
                  onTap: () => _openColorPicker(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------- Notifications ----------
          Text(
            "Notifications",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.primary),
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
                  subtitle: Text(
                    _notificationsEnabled
                        ? "You’ll receive reminders 🎶"
                        : "Currently turned off",
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _saveSetting('notifications', value);

                    if (value) {
                      await NotificationService.init();
                      await NotificationService.showNotification(
                        title: "Vibin’ Notifications",
                        body: "Notifications are now enabled ✅",
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notifications disabled ❌"),
                        ),
                      );
                    }
                  },
                ),
                SwitchListTile(
                  secondary: const Icon(Icons.music_note),
                  title: const Text("Sound Effects"),
                  value: _soundEnabled,
                  onChanged: (value) {
                    setState(() => _soundEnabled = value);
                    _saveSetting('sound', value);
                  },
                ),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text("Test Scheduled Notification"),
                    onPressed: () async {
                      await NotificationService.showScheduledNotification(
                        title: "Vibin Reminder 🎵",
                        body: "This is a scheduled test notification!",
                        seconds: 5,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Notification scheduled in 5 seconds"),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---------- Language ----------
          Text(
            "Language",
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.primary),
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
                // TODO: implement language selector
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _settingsBox.close();
    super.dispose();
  }
}
