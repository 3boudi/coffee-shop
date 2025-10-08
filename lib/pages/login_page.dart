import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:glassmorphism/glassmorphism.dart';

typedef AuthCallback = Future<void> Function(String email, String password);
typedef RegisterCallback =
    Future<void> Function(String email, String password, String name);

class LoginPage extends StatefulWidget {
  final AuthCallback onLogin;
  final RegisterCallback onRegister;
  final String? errorMessage;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onRegister,
    this.errorMessage,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _backgroundController;
  late AnimationController _formController;
  late AnimationController _buttonController;

  late Animation<double> _backgroundAnimation;
  late Animation<Offset> _formSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<double> _buttonScaleAnimation;

  bool _isRegister = false;
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Form animation controller
    _formController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Button animation controller
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Background floating animation
    _backgroundAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );

    // Form slide animation
    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _formController, curve: Curves.elasticOut),
        );

    // Form fade animation
    _formFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _formController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Button scale animation
    _buttonScaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    // Start animations
    _backgroundController.repeat();
    _formController.forward();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _formController.dispose();
    _buttonController.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    _buttonController.forward().then((_) => _buttonController.reverse());

    try {
      await widget.onLogin(_email.text.trim(), _password.text.trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    _buttonController.forward().then((_) => _buttonController.reverse());

    try {
      await widget.onRegister(
        _email.text.trim(),
        _password.text.trim(),
        _name.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegister = !_isRegister;
    });

    // Replay form animation
    _formController.reset();
    _formController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(size),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Header with animated logo and text
                  _buildHeader(),

                  const SizedBox(height: 40),

                  // Main form card
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(child: _buildFormCard()),
                    ),
                  ),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size size) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: size.width,
          height: size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
            ),
          ),
          child: Stack(
            children: [
              // Floating circles
              ...List.generate(6, (index) {
                final offset = _backgroundAnimation.value * 2 * 3.14159;
                final x =
                    size.width * 0.1 +
                    (size.width * 0.8) * ((index * 0.3 + offset) % 1);
                final y =
                    size.height * 0.1 +
                    (size.height * 0.8) * ((index * 0.2 + offset * 0.5) % 1);

                return Positioned(
                  left: x,
                  top: y,
                  child: Container(
                    width: 60 + (index * 20),
                    height: 60 + (index * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.brown.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Animated logo
        Hero(
              tag: 'logo',
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.brown.shade600, Colors.brown.shade800],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.coffee, color: Colors.white, size: 32),
              ),
            )
            .animate()
            .scale(duration: 800.ms, curve: Curves.elasticOut)
            .shimmer(duration: 2000.ms, color: Colors.brown.shade300),

        const SizedBox(width: 16),

        // Animated text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Coffee Cart',
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
              const SizedBox(height: 4),
              const Text(
                'Premium coffee, delivered fast',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ).animate().fadeIn(delay: 1500.ms, duration: 600.ms),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return SlideTransition(
      position: _formSlideAnimation,
      child: FadeTransition(
        opacity: _formFadeAnimation,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 600,
            borderRadius: 24,
            blur: 20,
            alignment: Alignment.bottomCenter,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                          _isRegister ? 'Create Account' : 'Welcome Back',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(
                          begin: -0.3,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      _isRegister
                          ? 'Join our coffee community today'
                          : 'Sign in to continue your coffee journey',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                    const SizedBox(height: 32),

                    // Form fields
                    ..._buildFormFields(),

                    const SizedBox(height: 24),

                    // Error message
                    if (widget.errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake(duration: 600.ms),

                    if (widget.errorMessage != null) const SizedBox(height: 24),

                    // Submit button
                    _buildSubmitButton(),

                    const SizedBox(height: 24),

                    // Toggle button
                    _buildToggleButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = <Widget>[];

    if (_isRegister) {
      fields.add(
        _buildTextField(
              controller: _name,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            )
            .animate()
            .slideX(begin: -0.3, duration: 600.ms, curve: Curves.easeOut)
            .fadeIn(duration: 600.ms),
      );
      fields.add(const SizedBox(height: 16));
    }

    fields.add(
      _buildTextField(
            controller: _email,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          )
          .animate()
          .slideX(
            begin: -0.3,
            duration: 600.ms,
            delay: 100.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 600.ms, delay: 100.ms),
    );

    fields.add(const SizedBox(height: 16));

    fields.add(
      _buildTextField(
            controller: _password,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          )
          .animate()
          .slideX(
            begin: -0.3,
            duration: 600.ms,
            delay: 200.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 600.ms, delay: 200.ms),
    );

    return fields;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.brown.shade300, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child:
          SizedBox(
                width: double.infinity,
                height: 56,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _loading
                      ? Container(
                          key: const ValueKey('loading'),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.brown.shade600,
                                Colors.brown.shade800,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          key: ValueKey(_isRegister ? 'register' : 'login'),
                          onPressed: _isRegister ? _doRegister : _doLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.brown.shade600,
                                  Colors.brown.shade800,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text(
                                _isRegister ? 'Create Account' : 'Sign In',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                ),
              )
              .animate()
              .slideY(
                begin: 0.3,
                duration: 600.ms,
                delay: 300.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 600.ms, delay: 300.ms),
    );
  }

  Widget _buildToggleButton() {
    return TextButton(
      onPressed: _toggleMode,
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
          children: [
            TextSpan(
              text: _isRegister
                  ? 'Already have an account? '
                  : 'Don\'t have an account? ',
            ),
            TextSpan(
              text: _isRegister ? 'Sign In' : 'Create Account',
              style: TextStyle(
                color: Colors.brown.shade300,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildFooter() {
    return Text(
      '© 2024 Coffee Cart',
      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
    ).animate().fadeIn(delay: 500.ms, duration: 600.ms);
  }
}
