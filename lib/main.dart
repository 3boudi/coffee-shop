import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart' hide Role;
import 'package:appwrite/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/notifications.dart';
import 'dart:convert';
import 'enums.dart';
// Use the new UI export surface instead of importing from `lib/pages/` directly.
import 'ui/views.dart';

Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message ${message.messageId}');
}

// Local notifications are implemented in `lib/core/notifications.dart`.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initLocalNotifications(); // ✅ Initialize local notifications (core)
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

  const String kAppwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  const String kAppwriteProjectId = '...';

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
    // Initialize app then prompt for notification permission
    _initializeApp();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptForNotificationPermission();
    });
  }

  Future<void> _promptForNotificationPermission() async {
    // Request platform notification permissions (iOS & Android as applicable)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('Requested Firebase messaging permission');
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));
    // Get and display FCM token on app start
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token: $fcmToken');
    // Foreground message handling: show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        '📩 Message received in foreground: ${message.notification?.title}',
      );

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        showLocalNotification(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
        );
      }
    });
    await _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Checking session...';
    });

    try {
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
      await _clearSession();
      debugPrint(
        '❌ Session check failed: ${e.message}, code: ${e.code}, type: ${e.type}',
      );

      if (e.code == 401) {
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = 'Session expired. Please log in again.';
        });
      } else {
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = 'Connection error. Please try again.';
        });
      }
    } catch (e) {
      debugPrint('⚠️ Unexpected error during session check: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'Unexpected error. Try again later.';
      });
    }
  }

  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_session', true);
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ---------- handlePostLogin method ----------
  Future<void> handlePostLogin(String userId) async {
    // 1. احصل على FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM token: $fcmToken');

    // 2. اطلب من Appwrite Function إرسال إشعار ترحيبي فوراً (بدون server manual)
    final functions = Functions(widget.account.client);
    final payload = {
      'userId': userId,
      'token': fcmToken,
      'title': 'Welcome 👋',
      'body': 'Thanks for logging in. Your coffee is waiting ☕',
    };

    final execution = await functions.createExecution(
      functionId: '68f33097003af1f0089a', // id ال function في Appwrite
      body: jsonEncode(payload),
    );

    debugPrint('Function execution: ${execution.$id}');
  }
  // ---------- end handlePostLogin method ----------

  // ---------- REPLACED login METHOD (only change) ----------
  Future<void> login(String email, String password, Role role) async {
    // prevent duplicate calls
    if (_currentState == AppState.loading) return;

    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Signing in...';
    });

    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    // try deleting any existing server session; ignore errors
    Future<void> forceDeleteServerSession() async {
      try {
        await widget.account.deleteSession(sessionId: 'current');

        debugPrint('Deleted existing server session (if any).');
      } catch (err) {
        debugPrint('No server session to delete or deletion failed: $err');
        // ignore and continue
      }
    }

    try {
      debugPrint('🔹 Attempting login for email: $trimmedEmail');

      // Ensure server session cleared before creating a new one
      await forceDeleteServerSession();

      // Create new session
      final session = await widget.account.createEmailPasswordSession(
        email: trimmedEmail,

        password: trimmedPassword,
      );

      debugPrint('✅ Session created: ${session.userId}');

      final user = await widget.account.get();

      // Verify role against user labels
      final userLabels = user.labels;
      final isOwner = userLabels.contains('owner');
      final isUser = userLabels.isEmpty || userLabels.contains('user');

      if (role == Role.owner && !isOwner) {
        await _clearSession();
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = 'Access denied. You are not an owner.';
        });
        return;
      }

      if (role == Role.user && !isUser) {
        await _clearSession();
        setState(() {
          _currentState = AppState.unauthenticated;
          _lastErrorMessage = 'Access denied. Invalid user role.';
        });
        return;
      }

      await _saveSession();

      setState(() {
        _loggedInUser = user;
        _currentState = AppState.authenticated;
        _lastErrorMessage = null;
      });

      // Send welcome notification
      try {
        await handlePostLogin(user.$id);
      } catch (e) {
        debugPrint('Failed to send welcome notification: $e');
        // Don't fail login if notification fails
      }

      debugPrint(
        '✅ Login successful for ${user.email} as ${role == Role.owner ? 'owner' : 'user'}',
      );
    } on AppwriteException catch (e) {
      debugPrint(
        '❌ Login error: ${e.message}, code: ${e.code}, type: ${e.type}',
      );

      // If server insists a session is already active, try delete & retry once
      if (e.type == 'user_session_already_exists' ||
          (e.message != null && e.message!.toLowerCase().contains('session'))) {
        debugPrint(
          'Detected existing server session. Deleting and retrying once...',
        );
        try {
          await widget.account.deleteSession(sessionId: 'current');
        } catch (delErr) {
          debugPrint('Failed deleting session before retry: $delErr');
        }

        // Retry once
        try {
          final retrySession = await widget.account.createEmailPasswordSession(
            email: trimmedEmail,
            password: trimmedPassword,
          );
          debugPrint('✅ Session created on retry: ${retrySession.userId}');

          final user = await widget.account.get();

          // Verify role against user labels
          final userLabels = user.labels;
          final isOwner = userLabels.contains('owner');
          final isUser = userLabels.isEmpty || userLabels.contains('user');

          if (role == Role.owner && !isOwner) {
            await _clearSession();
            setState(() {
              _currentState = AppState.unauthenticated;
              _lastErrorMessage = 'Access denied. You are not an owner.';
            });
            return;
          }

          if (role == Role.user && !isUser) {
            await _clearSession();
            setState(() {
              _currentState = AppState.unauthenticated;
              _lastErrorMessage = 'Access denied. Invalid user role.';
            });
            return;
          }

          await _saveSession();

          setState(() {
            _loggedInUser = user;
            _currentState = AppState.authenticated;
            _lastErrorMessage = null;
          });

          // Send welcome notification
          try {
            await handlePostLogin(user.$id);
          } catch (e) {
            debugPrint('Failed to send welcome notification: $e');
            // Don't fail login if notification fails
          }

          debugPrint(
            '✅ Login successful (retry) for ${user.email} as ${role == Role.owner ? 'owner' : 'user'}',
          );
          return;
        } on AppwriteException catch (e2) {
          debugPrint(
            '❌ Login error (retry): ${e2.message}, code: ${e2.code}, type: ${e2.type}',
          );
          await _clearSession();
          setState(() {
            _currentState = AppState.unauthenticated;
            _lastErrorMessage =
                'Invalid email or password (or session conflict).';
          });
          return;
        }
      }

      String friendlyMessage;
      switch (e.code) {
        case 401:
          friendlyMessage = 'Invalid email or password (401).';
          break;
        case 400:
          friendlyMessage = 'Bad request (400) — check your input.';
          break;
        case 404:
          friendlyMessage = 'Project or endpoint not found (404).';
          break;
        default:
          friendlyMessage = 'Login failed: ${e.message ?? 'Unknown error'}';
      }

      await _clearSession();

      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = friendlyMessage;
      });
    } catch (e) {
      debugPrint('⚠️ Unexpected login error: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'Unexpected error occurred.';
      });
    }
  }
  // ---------- end replaced login method ----------

  Future<void> register(String email, String password, String name) async {
    setState(() {
      _currentState = AppState.loading;
      _loadingMessage = 'Creating account...';
    });

    try {
      debugPrint('🟢 Registering new user: $email');
      final userId = ID.unique();
      await widget.account.create(
        userId: userId,
        email: email.trim(),
        password: password.trim(),
        name: name.trim(),
      );

      // Note: Labels are set during account creation in Appwrite, not updated afterward
      // The 'user' label will be set when the account is created

      await login(email, password, Role.user);
    } on AppwriteException catch (e) {
      debugPrint(
        '❌ Register error: ${e.message}, code: ${e.code}, type: ${e.type}',
      );

      String friendlyMessage;
      switch (e.code) {
        case 409:
          friendlyMessage = 'Email already in use.';
          break;
        case 400:
          friendlyMessage = 'Invalid registration details.';
          break;
        default:
          friendlyMessage =
              'Registration failed: ${e.message ?? 'Unknown error'}';
      }

      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = friendlyMessage;
      });
    } catch (e) {
      debugPrint('⚠️ Unexpected registration error: $e');
      setState(() {
        _currentState = AppState.unauthenticated;
        _lastErrorMessage = 'Unexpected error occurred.';
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
      });
      debugPrint('✅ Logout successful');
    } on AppwriteException catch (e) {
      debugPrint(
        '❌ Logout error: ${e.message}, code: ${e.code}, type: ${e.type}',
      );
      await _clearSession();
      setState(() {
        _loggedInUser = null;
        _currentState = AppState.unauthenticated;
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
        final userLabels = _loggedInUser!.labels;
        final isAdmin =
            userLabels.contains('admin') || userLabels.contains('owner');

        if (isAdmin) {
          return AdminDashboard(
            user: _loggedInUser!,
            onLogout: logout,
            client: widget.account.client,
          );
        } else {
          return UserHome(
            user: _loggedInUser!,
            onLogout: logout,
            client: widget.account.client,
          );
        }
      case AppState.unauthenticated:
        return LoginPage(
          onLogin: login,
          onRegister: register,
          errorMessage: _lastErrorMessage,
        );
    }
  }
}
