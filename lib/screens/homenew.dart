import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vibin/services/auth_service.dart'; // GoogleSignInProvider
import 'instrument_panel.dart';
import 'guitar.dart';
import 'mixer.dart';
import 'profile.dart';
import 'login.dart';
import 'aboutus.dart';
import 'admin.dart';
import 'settings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'projects.dart';
import 'thechat.dart';
import 'package:vibin/services/admin_service.dart';

// ---------------- Models ----------------
class Project {
  final String title;
  final DateTime lastModified;

  Project({required this.title, required this.lastModified});
}

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

// ---------------- HomeScreen ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  final List<Project> _allProjects = [
    Project(title: "Trap Vibes", lastModified: DateTime.now().subtract(const Duration(hours: 2))),
    Project(title: "Rock Riff", lastModified: DateTime.now().subtract(const Duration(days: 1))),
    Project(title: "Lofi Chill", lastModified: DateTime.now().subtract(const Duration(days: 3))),
  ];

  late List<SearchItem> _allItems;
  List<SearchItem> _filteredItems = [];

  @override
  void initState() {
    super.initState();

    // Listen to auth changes to handle Google & Guest users reactively
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });

    //_currentUser = FirebaseAuth.instance.currentUser;

    _allItems = [
      // Navigation
      SearchItem(title: "Instruments", icon: Icons.piano, type: "nav"),
      // SearchItem(title: "Mixer", icon: Icons.graphic_eq, type: "nav"),
      // SearchItem(title: "Loop Recorder", icon: Icons.loop, type: "nav"),
      SearchItem(title: "Projects", icon: Icons.folder, type: "nav"),
      SearchItem(title: "Challenges", icon: Icons.emoji_events, type: "nav"),
      SearchItem(title: "Profile", icon: Icons.person, type: "nav"),
      SearchItem(title: "Chatbot", icon: Icons.chat_outlined, type: "nav"),
      SearchItem(title: "About Us", icon: Icons.info_outline, type: "nav"),
      SearchItem(title: "Settings", icon: Icons.settings, type: "nav"),
      SearchItem(title: "Admin Panel", icon: Icons.space_dashboard, type: "nav"),
      SearchItem(title: "Guitar", icon: Icons.line_weight, type: "nav"),
      SearchItem(title: "Piano", icon: Icons.piano, type: "nav"),
      SearchItem(title: "Tabla", icon: Icons.wb_twilight_outlined, type: "nav"),

      // Projects
      //..._allProjects.map((p) => SearchItem(title: p.title, icon: Icons.music_note, type: "project", data: p)),
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
    final results = _allItems.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList();
    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;

    // Friendly display for guest users
    String displayName = _currentUser?.displayName?.isEmpty ?? true ? "Guest" : _currentUser!.displayName!;
    String email = (_currentUser?.email?.isEmpty ?? true)? "guest@example.com": _currentUser!.email!;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.colorScheme.surfaceContainer,
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
            : Text(
          " VIBIN'",
          style: GoogleFonts.monoton(
            fontSize: 32.0,
            color: Colors.purple,
            letterSpacing: 7,
          ),
        ),
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
              accountName: Text(displayName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _currentUser?.photoURL != null ? NetworkImage(_currentUser!.photoURL!) : AssetImage("assets/images/default_avatar.jpg"),
                //child: _currentUser?.photoURL == null ? const Icon(Icons.person, size: 40) : null,
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutUsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.space_dashboard),
              title: const Text("Admin Panel"),
              onTap: () async {
                // check if user is admin
                bool isAdmin = await checkIfAdmin();

                if (isAdmin) {
                  //if (true) {
                  // navigate if admin
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPanel()),
                  );
                } else {
                  // show message if not admin
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Access denied. Admins only.")),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Are you sure?"),
                    content: const Text("Do you really want to logout?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context).colorScheme.onError,
                        ),
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await AuthServe().signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const WelcomePage()), (route) => false);
                }
              },
            ),
          ],
        ),
      ),

      body: _isSearching ? _buildSearchResults(theme) : _buildHomeContent(theme, textColor),
    );
  }

  // ---------------- Search Results ----------------
  Widget _buildSearchResults(ThemeData theme) {
    if (_filteredItems.isEmpty) return const Center(child: Text("No matches found 😢"));

    final navItems = _filteredItems.where((item) => item.type == "nav").toList();
    final projectItems = _filteredItems.where((item) => item.type == "project").toList();

    return ListView(
      children: [
        if (navItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text("Navigation", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...navItems.map((item) => ListTile(
            leading: Icon(item.icon, color: theme.colorScheme.primary),
            title: Text(item.title),
            onTap: () => _openNavigation(item.title),
          )),
        ],
        if (projectItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text("Projects", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...projectItems.map((item) => ListTile(
            leading: Icon(item.icon, color: theme.colorScheme.secondary),
            title: Text(item.title),
            subtitle: item.data != null
                ? Text(
              "Last edited: ${item.data.lastModified.toLocal().toString().split(' ')[0]}",
              style: theme.textTheme.bodySmall,
            )
                : null,
            onTap: () => debugPrint("Open Project: ${item.title}"),
          )),
        ],
      ],
    );
  }

  // ---------------- Home Content ----------------
  Widget _buildHomeContent(ThemeData theme, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              " Welcome back, ${_currentUser?.displayName?.isEmpty ?? true ? "Guest" : _currentUser!.displayName!} 👋 ",
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 22),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            crossAxisSpacing: 13,
            mainAxisSpacing: 13,
            children: [
              buildTile(Icons.piano, "Instruments", Colors.redAccent.shade200),
              buildTile(Icons.folder, "Projects", Colors.orange),
              buildTile(Icons.emoji_events, "Challenges", Colors.blue),
              buildTile(Icons.chat, "Chatbot", Colors.green.shade500),
              // buildTile(Icons.piano, "Instruments", Colors.deepPurple.shade300),
              // buildTile(Icons.graphic_eq, "Mixer", Colors.redAccent.shade200),
              // buildTile(Icons.loop, "Loop Recorder", Colors.orange),
              // buildTile(Icons.folder, "Projects", Colors.blue),
              // buildTile(Icons.emoji_events, "Challenges", Colors.green.shade500),
              // buildTile(Icons.chat, "Chatbot", theme.brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey.shade600),
            ],
          ),

          // const SizedBox(height: 20),
          // Text("Featured", style: theme.textTheme.titleMedium),
          // const SizedBox(height: 10),
          // SizedBox(
          //   height: 100,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     children: [
          //       _buildFeatureCard("New: Jazz Piano 🎷", textColor, theme),
          //       _buildFeatureCard("Today's Challenge: LoFi Beat", textColor, theme),
          //       _buildFeatureCard("Update: Reverb FX added!", textColor, theme),
          //     ],
          //   ),
          // ),

          //   const SizedBox(height: 20),
          //   Text("Recent Projects", style: theme.textTheme.titleMedium),
          //   const SizedBox(height: 10),
          //   SizedBox(
          //     height: 80,
          //     child: ListView.separated(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: _allProjects.length,
          //       separatorBuilder: (_, __) => const SizedBox(width: 10),
          //       itemBuilder: (context, index) {
          //         final project = _allProjects[index];
          //         return Card(
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //           child: Container(
          //             width: 180,
          //             padding: const EdgeInsets.all(12),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(project.title, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          //                 const SizedBox(height: 4),
          //                 Text(
          //                   "Last edited: ${project.lastModified.toLocal().toString().split(' ')[0]}",
          //                   style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String text, Color textColor, ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, color: textColor))),
      ),
    );
  }

  void _openNavigation(String title) async{
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
    // case "Mixer":
    //   Navigator.push(context, MaterialPageRoute(builder: (_) => const MixerScreen()));
    //   break;
      case "Chatbot": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
        break;
      case "Projects": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectPage()));
        break;
      case "About Us": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsPage()));
        break;
      case "Challenges": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectPage()));
        break;
      case "Profile": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
      case "Settings": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
        break;
      case "Guitar": // NEW CASE
        Navigator.push(context, MaterialPageRoute(builder: (_) => const GuitarScreen()));
        break;
      case "Admin Panel": // NEW CASE
        bool isAdmin = await checkIfAdmin();
        if (isAdmin) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPanel()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Access denied. Admins only.")),
          );
        }
        break;
    }
  }

  Widget buildTile(IconData icon, String label, Color baseColor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardColor = Color.lerp(baseColor, isDark ? Colors.black : Colors.white, 0.65)!;

    return GestureDetector(
      onTap: () => _openNavigation(label),
      child: Hero(
        tag: label,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: baseColor, // Use the same color as the card's background
              width: 3.0, // Set the border thickness
            ),
          ),
          elevation: 3,
          color: cardColor,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: baseColor),
                const SizedBox(height: 10),
                Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: baseColor)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
