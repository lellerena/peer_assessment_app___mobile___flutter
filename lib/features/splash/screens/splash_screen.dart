import 'package:flutter/material.dart';
import '../controllers/splash_controller.dart';
import '../../../core/services/app_initialization_service.dart';
import '../../../core/services/splash_timer.dart';
import '../../../core/services/splash_navigation_service.dart';

/// Splash screen widget following SOLID principles
/// Single Responsibility: Display splash screen UI
/// Open/Closed: Can be extended for different splash designs
/// Dependency Inversion: Depends on SplashController abstraction
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SplashController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Dependency injection following Dependency Inversion Principle
    final initializationService = AppInitializationService();
    final timerService = SplashTimer();
    final navigationService = SplashNavigationService(context);

    _controller = SplashController(
      initializationService: initializationService,
      timerService: timerService,
      navigationService: navigationService,
    );

    // Start splash sequence
    _controller.initializeSplash();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return _buildSplashContent();
        },
      ),
    );
  }

  Widget _buildSplashContent() {
    if (_controller.errorMessage != null) {
      return _buildErrorContent();
    }

    return _buildLoadingContent();
  }

  Widget _buildLoadingContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.assessment,
                size: 80,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 40),

            // App Title
            const Text(
              'Peer Assessment App',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subtitle
            const Text(
              'Evaluate • Learn • Grow',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Loading indicator
            if (_controller.isLoading) ...[
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _controller.progress,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${(_controller.progress * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _controller.errorMessage ?? 'Unknown error occurred',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  _controller.initializeSplash();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6A1B9A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
