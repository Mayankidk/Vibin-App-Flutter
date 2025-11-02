import 'package:flutter/material.dart';

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

  void _navigate(String title) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tapped $title')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryGradient = isDark
        ? [const Color(0xFF2c0066), const Color(0xFF1A003C)]
        : [const Color(0xFF7912ff), const Color(0xFFe9d9ff)];
    final neonColor = theme.colorScheme.secondary;

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
                                  color: neonColor.withOpacity(0.5),
                                  blurRadius: _pulseAnimation.value,
                                  spreadRadius: _pulseAnimation.value / 2,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/300',
                          ),
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
                            onPressed: () => _navigate('Edit Profile Picture'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'User Name',
                    style: const TextStyle(
                      fontSize: 23, // manual font size
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'user@example.com',
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
                        side: BorderSide(color: Colors.blue, width: 2),
                      ),
                      //color: theme.cardColor,
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
                              '12',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Projects',
                              style: const TextStyle(
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
                              '5',
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
              //elevation: 6, // shadow effect
              color: theme.colorScheme.surfaceContainer,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    leading: Icon(Icons.person, size: 26),
                    title: Text(
                      'Username',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('Your Name', style: TextStyle(fontSize: 14)),
                    trailing: InkWell(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // optional for circular highlight
                      //onTap: () => _navigate('Username'),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0), // makes ripple visible
                        child: Icon(Icons.edit),
                      ),
                    ),
                  ),
                  Divider(height: 0, thickness: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.only(left: 16, right: 8),
                    leading: Icon(Icons.email, size: 26),
                    title: Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'namespace@example.com',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: InkWell(
                      borderRadius: BorderRadius.circular(
                        8,
                      ), // optional for circular highlight
                      //onTap: () => _navigate('Email'),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0), // makes ripple visible
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
                    //onTap: () => _navigate('Log Out'),
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
                    //onTap: () => _navigate('Delete Account'),
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
