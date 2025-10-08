import 'package:flutter/material.dart';

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

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();

  late AnimationController _anim;
  late Animation<Offset> _formOffset;
  bool _isRegister = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _formOffset = Tween(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutQuad));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() => _loading = true);
    try {
      await widget.onLogin(_email.text.trim(), _password.text.trim());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doRegister() async {
    setState(() => _loading = true);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient & subtle circles
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E2B2B), Color(0xFF512B28)],
              ),
            ),
          ),
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 0, 0, 0.06),
                borderRadius: BorderRadius.circular(110),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'logo',
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.brown.shade800,
                          child: const Icon(
                            Icons.coffee,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Coffee Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Fresh beans. Fast checkout.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SlideTransition(
                      position: _formOffset,
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 500),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: Card(
                              color: Colors.white,
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isRegister
                                          ? 'Create account'
                                          : 'Welcome back',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _isRegister
                                          ? 'Join Coffee Cart — great coffee, fast service.'
                                          : 'Sign in to continue to your coffee shop.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.black54),
                                    ),
                                    const SizedBox(height: 18),
                                    if (_isRegister)
                                      TextField(
                                        controller: _name,
                                        decoration: const InputDecoration(
                                          labelText: 'Full name',
                                        ),
                                      ),
                                    TextField(
                                      controller: _email,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 10),
                                    TextField(
                                      controller: _password,
                                      decoration: const InputDecoration(
                                        labelText: 'Password',
                                      ),
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 12),
                                    if (widget.errorMessage != null) ...[
                                      Text(
                                        widget.errorMessage!,
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 350,
                                        ),
                                        child: _loading
                                            ? Center(
                                                key: const ValueKey('loading'),
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          Colors.brown.shade700,
                                                    ),
                                              )
                                            : ElevatedButton(
                                                key: ValueKey(
                                                  _isRegister
                                                      ? 'register'
                                                      : 'login',
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.brown.shade700,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: _isRegister
                                                    ? _doRegister
                                                    : _doLogin,
                                                child: Text(
                                                  _isRegister
                                                      ? 'Create account'
                                                      : 'Sign in',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isRegister = !_isRegister;
                                          // replay the entrance animation
                                          _anim.reset();
                                          _anim.forward();
                                        });
                                      },
                                      child: Text(
                                        _isRegister
                                            ? 'Have an account? Sign in'
                                            : 'New here? Create account',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      ' Coffee Cart',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
