import 'package:flutter/material.dart';

class MixerScreen extends StatefulWidget {
  const MixerScreen({super.key});

  @override
  State<MixerScreen> createState() => _MixerScreenState();
}

class _MixerScreenState extends State<MixerScreen> {
  // Example track data
  List<Map<String, dynamic>> tracks = [
    {
      "name": "Track 1",
      "icon": Icons.music_note,
      "volume": 0.5,
      "pan": 0.0,
      "effects": 0.2,
      "mute": false,
      "solo": false,
    },
    {
      "name": "Track 2",
      "icon": Icons.music_note,
      "volume": 0.7,
      "pan": -0.3,
      "effects": 0.5,
      "mute": false,
      "solo": false,
    },
    {
      "name": "Track 3",
      "icon": Icons.music_note,
      "volume": 0.3,
      "pan": 0.4,
      "effects": 0.8,
      "mute": false,
      "solo": false,
    },
  ];

  int selectedTrackIndex = 0;

  final List<Map<String, dynamic>> instrumentOptions = [
    {"name": "Piano", "icon": Icons.piano},
    {
      "name": "Drums",
      "icon": Icons.music_note,
    }, // Can replace with custom drum icon
    {"name": "Guitar", "icon": Icons.queue_music},
    {"name": "Vocals", "icon": Icons.mic},
    {"name": "Bass", "icon": Icons.audiotrack},
  ];

  void _chooseTrackSource(int trackIndex) async {
    final chosen = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Track Source"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: instrumentOptions.length,
              itemBuilder: (context, index) {
                final option = instrumentOptions[index];
                return ListTile(
                  leading: Icon(option["icon"]),
                  title: Text(option["name"]),
                  onTap: () {
                    Navigator.pop(context, option);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (chosen != null) {
      setState(() {
        tracks[trackIndex]["name"] = chosen["name"];
        tracks[trackIndex]["icon"] = chosen["icon"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final track = tracks[selectedTrackIndex];

    return Scaffold(
      appBar: AppBar(title: const Text("Mixer"), centerTitle: true),
      body: Column(
        children: [
          // Track Selector
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedTrackIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      foregroundColor: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedTrackIndex = index;
                      });
                    },
                    onLongPress: () => _chooseTrackSource(
                      index,
                    ), // 👈 Long press to choose source
                    icon: Icon(tracks[index]["icon"]),
                    label: Text(tracks[index]["name"]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Mute / Solo buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text("Mute"),
                selected: track["mute"],
                onSelected: (val) {
                  setState(() {
                    track["mute"] = val;
                  });
                },
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text("Solo"),
                selected: track["solo"],
                onSelected: (val) {
                  setState(() {
                    track["solo"] = val;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Sliders
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSlider(
                    label: "Volume",
                    value: track["volume"],
                    min: 0,
                    max: 1,
                    onChanged: (val) {
                      setState(() {
                        track["volume"] = val;
                      });
                    },
                    color: Color.lerp(
                      Colors.green,
                      Colors.red,
                      track["volume"],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSlider(
                    label: "Pan (L ↔ R)",
                    value: track["pan"],
                    min: -1,
                    max: 1,
                    onChanged: (val) {
                      setState(() {
                        track["pan"] = val;
                      });
                    },
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 20),
                  _buildSlider(
                    label: "Effects",
                    value: track["effects"],
                    min: 0,
                    max: 1,
                    onChanged: (val) {
                      setState(() {
                        track["effects"] = val;
                      });
                    },
                    color:
                        theme.colorScheme.tertiary ?? theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ${(value * 100).round()}%",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            activeColor: color,
            inactiveColor: Colors.grey.withOpacity(0.3),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
