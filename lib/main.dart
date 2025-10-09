import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/splash_screen.dart';
import 'pages/loading_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use Appwrite Cloud endpoint and the project id you provided
  const String kAppwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  const String kAppwriteProjectId = '';

  final client = Client()
      .setEndpoint(kAppwriteEndpoint)
      .setProject(kAppwriteProjectId);

  final account = Account(client);

  runApp(MyApp(account: account));
}

class MyApp extends StatefulWidget {
  final Account account;

  const MyApp({super.key, required this.account});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppState { splash, loading, authenticated, unauthenticated }

class _MyAppState extends State<MyApp> {
  AppState _currentState = AppState.splash;
  models.User? _loggedInUser;
  String? _lastErrorMessage;
  String _loadingMessage = 'Loading...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check for existing session
    await _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Checking session...';
    });

    try {
      // Check if user has a saved session
      final prefs = await SharedPreferences.getInstance();
      final hasSession = prefs.getBool('has_session') ?? false;

      if (hasSession) {
        final user = await widget.account.get();
        setState(() {
          _loggedInUser = user;
          _currentState = AppState.authenticated;
          _lastErrorMessage = null;
        });
      } else {
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = null;
        });
      }
    } on AppwriteException catch (e) {
      // Clear invalid session
      await _clearSession();

      final isAuthError =
          e.code == 401 ||
          (e.message != null &&
              e.message!.toLowerCase().contains('missing scope'));

      if (isAuthError) {
        debugPrint('No valid session found');
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = null;
        });
      } else {
        debugPrint('Session check error: ${e.message} (code: ${e.code})');
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = 'Connection error. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('Unexpected error during session check: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'An unexpected error occurred.';
      });
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_session', true);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_session');
  }

  Future<void> login(String email, String password) async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Signing in...';
    });

    try {
      await widget.account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await widget.account.get();
      await _saveSession();

      setState(() {
        _loggedInUser = user;
        _currentState = AppState.authenticated;
        _lastErrorMessage = null;
      });
    } on AppwriteException catch (e) {
      debugPrint('Login error: ${e.message} (code: ${e.code})');

      String friendlyMessage;
      if (e.code == 401) {
        friendlyMessage = 'Invalid email or password';
      } else if (e.code == 404) {
        friendlyMessage = 'Server not found. Please check your connection.';
      } else {
        friendlyMessage = 'Login failed. Please try again.';
      }

      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = friendlyMessage;
      });
    } catch (e) {
      debugPrint('Unexpected login error: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'An unexpected error occurred.';
      });
    }
  }

  Future<void> register(String email, String password, String name) async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Creating account...';
    });

    try {
      await widget.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Auto login after registration
      await login(email, password);
    } on AppwriteException catch (e) {
      debugPrint('Register error: ${e.message} (code: ${e.code})');

      String friendlyMessage;
      if (e.code == 409) {
        friendlyMessage = 'An account with this email already exists';
      } else if (e.code == 400) {
        friendlyMessage = 'Invalid registration details';
      } else {
        friendlyMessage = 'Registration failed. Please try again.';
      }

      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = friendlyMessage;
      });
    } catch (e) {
      debugPrint('Unexpected registration error: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'An unexpected error occurred.';
      });
    }
  }

  Future<void> logout() async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Signing out...';
    });

    try {
      await widget.account.deleteSession(sessionId: 'current');
      await _clearSession();

      setState(() {
        _loggedInUser = null;
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = null;
      });
    } on AppwriteException catch (e) {
      debugPrint('Logout error: ${e.message} (code: ${e.code})');
      // Even if logout fails, clear local session
      await _clearSession();
      setState(() {
        _loggedInUser = null;
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = null;
      });
    } catch (e) {
      debugPrint('Unexpected logout error: $e');
      // Even if logout fails, clear local session
      await _clearSession();
      setState(() {
        _loggedInUser = null;
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentState) {
      case AppState.splash:
        return const SplashScreen();

      case AppState.loading:
        return LoadingScreen(message: _loadingMessage);

      case AppState.authenticated:
        return HomePage(user: _loggedInUser!, onLogout: logout);

      case AppState.unauthenticated:
        return LoginPage(
          onLogin: login,
          onRegister: register,
          errorMessage: _lastErrorMessage,
        );
    }
  }
}
