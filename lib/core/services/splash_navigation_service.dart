import 'package:flutter/material.dart';
import '../contracts/splash_contract.dart';

/// Navigation service for splash screen
/// Following Single Responsibility Principle (SRP) and Dependency Inversion Principle (DIP)
class SplashNavigationService implements SplashNavigationContract {
  final BuildContext _context;

  SplashNavigationService(this._context);

  @override
  Future<void> navigateToNextScreen() async {
    if (!_context.mounted) return;

    // Navigate to the main app screen
    Navigator.of(_context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainAppScreen()),
    );
  }
}

/// Placeholder for the main app screen
/// In a real app, this would be your home screen or login screen
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Assessment App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assessment, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Welcome to Peer Assessment App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Your assessment journey starts here',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
