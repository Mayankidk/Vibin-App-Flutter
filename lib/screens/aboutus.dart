import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: Text(
          'About Us',
          style: TextStyle(fontSize: 22, color: theme.colorScheme.onSurface),
        ),
        centerTitle: true, // <-- centers the title
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSurface,
            ), // <-- right icon
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro Section inside a Card
            Card(
              color: theme.colorScheme.secondaryContainer.withAlpha(
                isDark ? 120 : 255,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Build. Play. Vibe.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary, // dynamic purple
                          //color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Music is everywhere. Now, so is your studio. Vibin\' was born from a simple idea: that anyone, anywhere, should be able to create their own track right from their phone.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We built this app for the dreamers, the beat-makers, and anyone ready to turn a simple idea into a drop-worthy track. We\'re not here to be another complex, overwhelming tool. We\'re here to be your musical sidekick.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Purpose Section
            Card(
              color: theme.colorScheme.secondaryContainer.withAlpha(
                isDark ? 120 : 255,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              //margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Our Purpose',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    _buildPurposeSubCard(
                      context,
                      icon: Icons.flash_on,
                      title: 'Simplicity',
                      description:
                          'We stripped away the complexity so you can focus on the fun part: making music.',
                    ),
                    const SizedBox(height: 4),
                    _buildPurposeSubCard(
                      context,
                      icon: Icons.phone_android,
                      title: 'Portability',
                      description:
                          'Your phone is always with you, and now your music studio is, too.',
                    ),
                    const SizedBox(height: 4),
                    _buildPurposeSubCard(
                      context,
                      icon: Icons.music_note,
                      title: 'Creativity',
                      description:
                          'We provide the building blocks, the kicks, snares, and melodies. So you have the freedom to arrange them however you want.',
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Text(
                        'Vibin\' is for everyone who has ever had a beat in their head and needed a simple way to get it out. We’re just trying to help you create your own little piece of the music world.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Connect with Us Section
            Card(
              color: theme.colorScheme.secondaryContainer.withAlpha(
                isDark ? 120 : 255,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              //margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Connect with Us',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildContactSubCard(
                      context,
                      icon: Icons.email,
                      text: 'Email: your-email@gmail.com',
                      onTap: () => _launchURL('mailto:your-email@gmail.com'),
                    ),
                    const SizedBox(height: 2),
                    _buildContactSubCard(
                      context,
                      icon: Icons.code,
                      text: 'GitHub: your-github-link',
                      onTap: () => _launchURL(
                        'https://github.com/your-username/your-repo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    _buildContactSubCard(
                      context,
                      icon: Icons.person,
                      text: 'Portfolio: your-portfolio-link',
                      onTap: () => _launchURL('https://your-portfolio.com'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Purpose sub-cards
  Widget _buildPurposeSubCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      //color: theme.colorScheme..withAlpha(isDark?155:255), // adapts to light/dark
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.4,
                      color: theme.colorScheme.onSurface,
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

  // Contact sub-cards
  Widget _buildContactSubCard(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      //color: theme.colorScheme.onPrimary.withAlpha(isDark?155:255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Row(
            children: [
              Icon(icon, size: 24, color: theme.colorScheme.primary),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
