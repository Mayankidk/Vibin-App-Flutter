// instrument_panel.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final List<Map<String, String>> instruments = [
  {"name": "Piano", "image": "assets/images/piano.png"},
  {"name": "Guitar", "image": "assets/images/guitar.png"},
  {"name": "Drums", "image": "assets/images/drums.png"},
  {"name": "Violin", "image": "assets/images/violin.png"},
];

class InstrumentPanel extends StatelessWidget {
  const InstrumentPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.83,
      minChildSize: 0.7,
      maxChildSize: 0.83,
      builder: (context, scrollController) {
        // Corrected: SafeArea is the top-level widget here
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A003C) : Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 5,
                  width: 100,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text(
                    "Instruments",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                // Grid
                Expanded(
                  child: GridView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600
                          ? 2
                          : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 5 / 2,
                    ),
                    itemCount: instruments.length,
                    itemBuilder: (context, index) {
                      final instrument = instruments[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // handle selection here
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(instrument['image']!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16,
                                bottom: 8,
                              ),
                              child: Text(
                                instrument['name']!,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
