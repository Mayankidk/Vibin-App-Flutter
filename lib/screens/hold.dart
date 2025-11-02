import 'package:flutter/material.dart';
import 'instrument_panel.dart';
import 'mixer.dart';
import 'profile.dart';
import 'login.dart';
import 'aboutus.dart';

// Dummy Project Model
class Project {
  final String title;
  final DateTime lastModified;

  Project({required this.title, required this.lastModified});
}

// Search Item Model
class SearchItem {
  final String title;
  final IconData icon;
  final String type; // 'nav' or 'project'
  final dynamic data;

  SearchItem({
    required this.title,
    required this.icon,
    required this.type,
    this.data,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = "Devil";

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Project> _allProjects = [
    Project(
      title: "Trap Vibes",
      lastModified: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Project(
      title: "Rock Riff",
      lastModified: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Project(
      title: "Lofi Chill",
      lastModified: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  late List<SearchItem> _allItems;
  List<SearchItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();

    _allItems = [
      // Navigation items
      SearchItem(title: "Instruments", icon: Icons.piano, type: "nav"),
      SearchItem(title: "Mixer", icon: Icons.graphic_eq, type: "nav"),
      SearchItem(title: "Loop Recorder", icon: Icons.loop, type: "nav"),
      SearchItem(title: "Projects", icon: Icons.folder, type: "nav"),
      SearchItem(title: "Challenges", icon: Icons.emoji_events, type: "nav"),
      SearchItem(title: "Profile", icon: Icons.person, type: "nav"),
      SearchItem(title: "Settings", icon: Icons.settings, type: "nav"),

      // Projects
      ..._allProjects.map(
        (p) => SearchItem(
          title: p.title,
          icon: Icons.music_note,
          type: "project",
          data: p,
        ),
      ),
    ];

    _filteredItems = _allItems;
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredItems = _allItems;
      }
    });
  }

  void _filterSearch(String query) {
    final results = _allItems
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onBackground;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterSearch,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search everything...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : const Text("VIBIN' 🎶"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),

      drawer: Drawer(
        width: 200,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: const Text("devil@example.com"),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/icon.png'),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("About Us"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false, // removes all previous routes
                );
              },
            ),
          ],
        ),
      ),

      body: _isSearching
          ? _buildSearchResults(theme)
          : _buildHomeContent(theme, textColor),
    );
  }

  // 🔍 Search Results View
  Widget _buildSearchResults(ThemeData theme) {
    if (_filteredItems.isEmpty) {
      return const Center(child: Text("No matches found 😢"));
    }

    return ListView.builder(
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return ListTile(
          leading: Icon(item.icon, color: theme.colorScheme.primary),
          title: Text(item.title),
          onTap: () {
            if (item.type == "nav") {
              _openNavigation(item.title);
            } else if (item.type == "project") {
              debugPrint("Open Project: ${item.title}");
            }
          },
        );
      },
    );
  }

  // 🏠 Normal Home UI
  Widget _buildHomeContent(ThemeData theme, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome back, $userName 👋",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          // const SizedBox(height: 4),
          // Text("Last Project: $lastProject 🎵",
          //     style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 20),

          // Quick Access
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            children: [
              buildTile(Icons.piano, "Instruments", Colors.deepPurple.shade300),
              buildTile(Icons.graphic_eq, "Mixer", Colors.redAccent.shade400),
              buildTile(Icons.loop, "Loop Recorder", Colors.orange),
              buildTile(Icons.folder, "Projects", Colors.blue),
              buildTile(
                Icons.emoji_events,
                "Challenges",
                Colors.green.shade500,
              ),
              buildTile(Icons.settings, "Settings", Colors.grey.shade300),
            ],
          ),

          const SizedBox(height: 20),

          // Featured
          Text("Featured", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFeatureCard("New: Jazz Piano 🎷", textColor, theme),
                _buildFeatureCard(
                  "Today's Challenge: LoFi Beat",
                  textColor,
                  theme,
                ),
                _buildFeatureCard("Update: Reverb FX added!", textColor, theme),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recent Projects
          Text("Recent Projects", style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _allProjects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final project = _allProjects[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Last edited: ${project.lastModified.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
    );
  }

  Widget _buildFeatureCard(String text, Color textColor, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: theme.colorScheme.primary.withOpacity(0.1),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
          ),
        ),
      ),
    );
  }

  void _openNavigation(String title) {
    switch (title) {
      case "Instruments":
        showModalBottomSheet(
          context: context,
          useSafeArea: true,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const SafeArea(child: InstrumentPanel()),
        );
        break;
      case "Mixer":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MixerScreen()),
        );
        break;
      case "Profile":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
      // Add other cases if needed
    }
  }

  Widget buildTile(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => _openNavigation(label),
      child: Hero(
        tag: label,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: color.withOpacity(0.1),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
