import 'package:flutter/material.dart';
import 'package:appwrite/models.dart' as models;

class HomePage extends StatelessWidget {
  final models.User user;
  final VoidCallback onLogout;

  const HomePage({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.coffee, size: 96),
            const SizedBox(height: 12),
            Text('Welcome, ${user.name}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Email: ${user.email}'),
          ],
        ),
      ),
    );
  }
}
