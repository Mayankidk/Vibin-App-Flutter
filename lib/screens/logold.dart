import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:vibin/services/auth_service.dart';

// Neon gradient palette
const List<Color> neonGradient = [
  Color(0xFFff00ff), // Pink
  Color(0xFF00ffff), // Cyan
  Color(0xFFff9900), // Orange
];

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const NeonGlowIcon(Icons.music_note_rounded, 90),
              const SizedBox(height: 20),
              const NeonGlowText("Welcome to VIBIN’", 32, FontWeight.bold),
              const SizedBox(height: 10),
              Text(
                "Your music. Your vibe.\nJoin the rhythm now!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 30),

              // 🌐 Google Login Button (outlined style visually)
              OutlinedButton.icon(
                onPressed: () async {
                  final userCredential = await AuthServe().signInWithGoogle();

                  if (userCredential != null) {
                    // Successful login → Navigate to HomeScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  } else {
                    // User cancelled or error
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Google sign-in cancelled or failed."),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.g_mobiledata_rounded, size: 35),
                label: const Text("Continue with Google"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.blueGrey : Colors.blueGrey,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(
                    screenWidth > 800 ? 400 : screenWidth * 0.8,
                    48,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Sign Up Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.blueGrey : Colors.blueGrey,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(
                    screenWidth > 800 ? 400 : screenWidth * 0.8,
                    48,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupPage()),
                  );
                },
                child: const Text("Sign Up"),
              ),

              const SizedBox(height: 15),

              // Continue as Guest Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? Colors.blueGrey : Colors.blueGrey,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(
                    screenWidth > 800 ? 400 : screenWidth * 0.8,
                    48,
                  ),
                ),
                onPressed: () async {
                  try {
                    final userCredential = await AuthServe().signInAnonymously();
                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Guest login failed")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Guest login failed: $e")),
                    );
                  }
                },
                child: const Text("Continue as Guest"),
              ),

              const SizedBox(height: 15),

              // Already have an account? Log In
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.cyanAccent[400],
                        decorationColor: Colors.cyanAccent[400],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NeonGlowText("USER LOGIN", 28, FontWeight.bold),
              const SizedBox(height: 8),
              Text(
                "Welcome Back!",
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField("Email", Icons.email, isDark: isDark),
              const SizedBox(height: 16),

              // Password + Forgot
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      "Password",
                      Icons.lock,
                      isPassword: true,
                      isDark: isDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PasswordResetPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot?",
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              // Remember me
              Row(
                children: [
                  Checkbox(
                    value: rememberMe,
                    activeColor: isDark ? Colors.white : Colors.black,
                    checkColor: isDark ? Colors.black : Colors.white,
                    onChanged: (value) {
                      setState(() {
                        rememberMe = value ?? false;
                      });
                    },
                  ),
                  Text(
                    "Remember me",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              _gradientButton(
                text: "Log In",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _appBar(context),
      body: _formBody(
        title: "HELLO THERE!",
        subtitle: "Don't have an account? Create one",
        fields: [
          _buildTextField("Username", Icons.person, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField("Email", Icons.email, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField(
            "Password",
            Icons.lock,
            isPassword: true,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "Confirm Password",
            Icons.lock,
            isPassword: true,
            isDark: isDark,
          ),
        ],
        buttonText: "Sign Up",
        isDark: isDark,
      ),
    );
  }
}

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _appBar(context),
      body: _formBody(
        title: "RESET PASSWORD",
        subtitle: "Enter your email to reset password",
        fields: [_buildTextField("Email", Icons.email, isDark: isDark)],
        buttonText: "Send Reset Link",
        isDark: isDark,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: const Center(
        child: NeonGlowText("Home Screen!", 28, FontWeight.bold),
      ),
    );
  }
}

// ---------------- Shared Widgets ----------------

PreferredSizeWidget _appBar(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: const NeonGlowIcon(Icons.arrow_back, 26),
      onPressed: () => Navigator.pop(context),
      color: isDark ? Colors.white : Colors.black,
    ),
  );
}

Widget _formBody({
  required String title,
  required String subtitle,
  required List<Widget> fields,
  required String buttonText,
  required bool isDark,
}) {
  return Padding(
    padding: const EdgeInsets.all(32),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NeonGlowText(title, 28, FontWeight.bold),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 24),
          ...fields,
          const SizedBox(height: 24),
          _gradientButton(text: buttonText, onPressed: () {}, isDark: isDark),
        ],
      ),
    ),
  );
}

Widget _buildTextField(
    String hint,
    IconData icon, {
      bool isPassword = false,
      required bool isDark,
    }) {
  return TextField(
    obscureText: isPassword,
    style: TextStyle(color: isDark ? Colors.white : Colors.black),
    decoration: InputDecoration(
      prefixIcon: NeonGlowIcon(icon, 24),
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

// Neon glowing text with animation
class NeonGlowText extends StatefulWidget {
  final String text;
  final double size;
  final FontWeight weight;

  const NeonGlowText(this.text, this.size, this.weight, {super.key});

  @override
  State<NeonGlowText> createState() => _NeonGlowTextState();
}

class _NeonGlowTextState extends State<NeonGlowText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 8,
      end: 16,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: neonGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.size,
              fontWeight: widget.weight,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: _glowAnimation.value,
                  color: Colors.pinkAccent.withValues(alpha: 0.8),
                ),
                Shadow(
                  blurRadius: _glowAnimation.value * 1.5,
                  color: Colors.cyanAccent.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Neon glowing icon with animation
class NeonGlowIcon extends StatefulWidget {
  final IconData icon;
  final double size;

  const NeonGlowIcon(this.icon, this.size, {super.key});

  @override
  State<NeonGlowIcon> createState() => _NeonGlowIconState();
}

class _NeonGlowIconState extends State<NeonGlowIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(
      begin: 5,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: neonGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: _glowAnimation.value,
                color: Colors.pinkAccent.withValues(alpha: 0.8),
              ),
              Shadow(
                blurRadius: _glowAnimation.value * 1.5,
                color: Colors.cyanAccent.withValues(alpha: 0.6),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Gradient neon button
Widget _gradientButton({
  required String text,
  required VoidCallback onPressed,
  required bool isDark,
}) {
  return Container(
    width: double.infinity,
    height: 48,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: neonGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.pinkAccent.withValues(alpha: 0.6),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.black.withValues(alpha: 0.85) : Colors.black54,
        ),
      ),
    ),
  );
}