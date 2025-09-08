import 'package:flutter/material.dart';
import '../../domain/services/app_initialization_service.dart';
import '../../domain/services/splash_timer.dart';
import '../../domain/services/splash_navigation_service.dart';
import '../widgets/loading_content.dart';
import '../widgets/error_content.dart';
import '../controllers/splash_controller.dart';

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
    final initializationService = AppInitializationService();
    final timerService = SplashTimer();
    final navigationService = SplashNavigationService(context);

    _controller = SplashController(
      initializationService: initializationService,
      timerService: timerService,
      navigationService: navigationService,
    );

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
      return ErrorContent(
        errorMessage: _controller.errorMessage,
        onRetry: () => _controller.initializeSplash(),
      );
    }

    return LoadingContent(
      isLoading: _controller.isLoading,
      progress: _controller.progress,
    );
  }
}
