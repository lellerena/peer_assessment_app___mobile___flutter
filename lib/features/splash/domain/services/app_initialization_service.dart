import '../repositories/splash_repository.dart';

/// Service responsible for app initialization tasks
/// Following Single Responsibility Principle (SRP)
class AppInitializationService implements SplashInitializationContract {
  bool _isInitialized = false;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Future<void> initialize() async {
    try {
      // Simulate initialization tasks
      await _loadConfiguration();
      await _initializeServices();
      await _checkPermissions();

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> _loadConfiguration() async {
    // Simulate loading app configuration
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _initializeServices() async {
    // Simulate initializing necessary services
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _checkPermissions() async {
    // Simulate checking required permissions
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
