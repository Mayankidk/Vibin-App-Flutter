import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:vibin/services/auth_service.dart';

// Neon gradient palette
const List<Color> neonGradient = [
  Color(0xFFff00ff), // Pink
  Color(0xFF00ffff), // Cyan
  Color(0xFFff9900), // Orange
];

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
  VoidCallback? onButtonPressed,
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
          _gradientButton(
            text: buttonText,
            onPressed: onButtonPressed ?? () {},
            isDark: isDark,
          ),
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
      TextEditingController? controller,
    }) {
  return StatefulBuilder(
    builder: (context, setState) {
      // keep state in closure, not reset on rebuild
      return _PasswordTextField(
        hint: hint,
        icon: icon,
        isPassword: isPassword,
        isDark: isDark,
        controller: controller,
      );
    },
  );
}

class _PasswordTextField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool isDark;
  final TextEditingController? controller;

  const _PasswordTextField({
    required this.hint,
    required this.icon,
    required this.isPassword,
    required this.isDark,
    this.controller,
  });

  @override
  State<_PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isPassword; // default hidden if password
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      style: TextStyle(color: widget.isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        prefixIcon: NeonGlowIcon(widget.icon, 24),
        hintText: widget.hint,
        hintStyle: TextStyle(
          color: widget.isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        filled: true,
        fillColor: widget.isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: widget.isDark ? Colors.white70 : Colors.black54,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        )
            : null,
      ),
    );
  }
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
    _glowAnimation = Tween<double>(begin: 8, end: 16).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
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
    _glowAnimation = Tween<double>(begin: 5, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
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

// ---------------- Pages ----------------

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

              OutlinedButton.icon(
                onPressed: () async {
                  final userCredential = await AuthServe().signInWithGoogle();
                  if (userCredential != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  } else {
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
                  side: BorderSide(color: isDark ? Colors.blueGrey : Colors.blueGrey, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(screenWidth > 800 ? 400 : screenWidth * 0.8, 48),
                ),
              ),

              const SizedBox(height: 15),

              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupPage()),
                  );
                },
                child: const Text("Sign Up"),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.blueGrey : Colors.blueGrey, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(screenWidth > 800 ? 400 : screenWidth * 0.8, 48),
                ),
              ),

              const SizedBox(height: 15),

              OutlinedButton(
                onPressed: () async {
                  try {
                    final userCredential = await AuthServe().signInAnonymously();
                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
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
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: isDark ? Colors.blueGrey : Colors.blueGrey, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  minimumSize: Size(screenWidth > 800 ? 400 : screenWidth * 0.8, 48),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.cyanAccent[400],
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.cyanAccent[400],
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

// ---------------- Login Page ----------------

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              Text(
                "Welcome Back!",
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              _buildTextField(
                "Email",
                Icons.email,
                controller: _emailController,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _PasswordTextField(
                      hint: "Password",
                      icon: Icons.lock,
                      controller: _passwordController,
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
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700], fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _gradientButton(
                text: "Log In",
                isDark: isDark,
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();
                  try {
                    final user = await AuthServe().signInWithEmail(email, password);
                    if (user != null) {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login failed. Check credentials.")));
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Signup Page ----------------

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController  = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: _appBar(context),
      body: _formBody(
        title: "HELLO THERE!",
        subtitle: "Don't have an account? Create one",
        fields: [
          _buildTextField("Username", Icons.person, controller: _usernameController, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField("Email", Icons.email, controller: _emailController, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField("Password", Icons.lock, isPassword: true, controller: _passwordController, isDark: isDark),
          const SizedBox(height: 16),
          _buildTextField("Confirm Password", Icons.lock, isPassword: true, controller: _confirmController, isDark: isDark),
        ],
        buttonText: "Sign Up",
        isDark: isDark,
        onButtonPressed: () async {
          final username = _usernameController.text.trim();
          final email    = _emailController.text.trim();
          final password = _passwordController.text.trim();
          final confirm  = _confirmController.text.trim();

          if (password != confirm) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
            return;
          }

          try {
            final user = await AuthServe().signUpWithEmail(email, password, username);
            if (user != null) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup failed")));
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
          }
        },
      ),
    );
  }
}

// class PasswordResetPage extends StatelessWidget {
//   const PasswordResetPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       appBar: _appBar(context),
//       body: _formBody(
//         title: "RESET PASSWORD",
//         subtitle: "Enter your email to reset password",
//         fields: [_buildTextField("Email", Icons.email, isDark: isDark)],
//         buttonText: "Send Reset Link",
//         isDark: isDark,
//       ),
//     );
//   }
// }
// Make sure this path is correct

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final TextEditingController _emailController = TextEditingController();
  final AuthServe _authService = AuthServe();
  // Or get this from your theme/state
  bool _isLoading = false;
  String? _message;

  Future<void> _sendPasswordResetEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      setState(() {
        _message = "Password reset link sent! Check your email.";
      });
    } catch (e) {
      setState(() {
        _message = "Error: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: _appBar(context),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NeonGlowText('Reset Password', 28, FontWeight.bold),
              const SizedBox(height: 8),
              Text(
                'Enter email to receive password reset link.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField("Email", Icons.email, isDark: isDark),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _gradientButton(
                text: 'Send Reset Link',
                onPressed: _sendPasswordResetEmail,
                isDark: isDark,
              ),
              const SizedBox(height: 24),
              if (_message != null)
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.contains('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}