import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'pages/home_page.dart';
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use Appwrite Cloud endpoint and the project id you provided
  const String kAppwriteEndpoint = 'https://fra.cloud.appwrite.io/v1';
  const String kAppwriteProjectId = '68bf228300007baa47f9';

  final client = Client()
      .setEndpoint(kAppwriteEndpoint)
      .setProject(kAppwriteProjectId); // رقم المشروع

  final account = Account(client);

  runApp(MyApp(account: account));
}

class MyApp extends StatefulWidget {
  final Account account;

  const MyApp({super.key, required this.account});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  models.User? loggedInUser;
  String? lastErrorMessage;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Try to get the current user on startup so the app shows the Home page
    // if a session already exists. This also surfaces connection errors early.
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = await widget.account.get();
      setState(() => loggedInUser = user);
    } on AppwriteException catch (e) {
      // If the call is unauthorized or the user is a guest missing scopes,
      // treat this as "not logged in" (normal on first app start) and don't
      // surface an alarming error to the user. Only surface other error types.
      final isAuthError =
          e.code == 401 ||
          (e.message != null &&
              e.message!.toLowerCase().contains('missing scope'));
      if (isAuthError) {
        debugPrint('Startup: no session (user unauthenticated)');
        setState(() {
          lastErrorMessage = null;
          loggedInUser = null;
        });
        return;
      }

      final msg = 'Startup: ${e.message} (code: ${e.code})';
      // Keep full details in logs but show a short friendlier message.
      debugPrint('Startup: could not fetch current user: $msg');
      setState(() {
        lastErrorMessage = 'Unable to contact authentication server.';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError('Connection problem — please check your network.');
      });
    } catch (e, st) {
      debugPrint('Startup: unexpected error fetching user: $e\n$st');
      setState(() {
        lastErrorMessage = 'Unexpected error during startup.';
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError('An unexpected error occurred.');
      });
    }
  }

  // تسجيل الدخول
  Future<void> login(String email, String password) async {
    try {
      await widget.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await widget.account.get();
      setState(() {
        loggedInUser = user;
        // Clear input fields and any previous error after successful login
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        lastErrorMessage = null;
      });
    } on AppwriteException catch (e) {
      final msg = 'Login error: ${e.message} (code: ${e.code})';
      // Full details in logs for debugging
      debugPrint(msg);
      // Provide a short, user-friendly message on screen
      String friendly;
      if (e.code == 401) {
        friendly = 'Login failed — check your credentials.';
      } else if (e.code == 404) {
        friendly = 'Login failed — server not found.';
      } else if (e.code == 409) {
        friendly = 'Login failed — user may already exist.';
      } else {
        friendly = 'Login failed — please try again.';
      }
      setState(() {
        lastErrorMessage = friendly;
      });
      _showError(friendly);
    }
  }

  // التسجيل
  Future<void> register(String email, String password, String name) async {
    try {
      await widget.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      await login(email, password);
    } on AppwriteException catch (e) {
      final msg = 'Register error: ${e.message} (code: ${e.code})';
      debugPrint(msg);
      String friendly;
      if (e.code == 409) {
        friendly = 'Registration failed — user already exists.';
      } else if (e.code == 400) {
        friendly = 'Registration failed — invalid input.';
      } else {
        friendly = 'Registration failed — please try again.';
      }
      setState(() {
        lastErrorMessage = friendly;
      });
      _showError(friendly);
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    try {
      await widget.account.deleteSession(sessionId: 'current');
      setState(() {
        loggedInUser = null;
        // Clear any sensitive data and error state on logout
        emailController.clear();
        passwordController.clear();
        nameController.clear();
        lastErrorMessage = null;
      });
    } on AppwriteException catch (e) {
      final msg = 'Logout error: ${e.message} (code: ${e.code})';
      debugPrint(msg);
      setState(() {
        lastErrorMessage = 'Logout failed.';
      });
      _showError('Logout failed.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: loggedInUser != null
          ? HomePage(user: loggedInUser!, onLogout: logout)
          : LoginPage(
              onLogin: (email, password) => login(email, password),
              onRegister: (email, password, name) =>
                  register(email, password, name),
              errorMessage: lastErrorMessage,
            ),
    );
  }
}
