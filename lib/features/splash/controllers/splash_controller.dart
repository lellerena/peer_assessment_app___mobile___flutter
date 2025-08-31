import 'package:flutter/foundation.dart';
import '../../../core/contracts/splash_contract.dart';
import '../../../core/services/app_initialization_service.dart';
import '../../../core/services/splash_timer.dart';
import '../../../core/services/splash_navigation_service.dart';

/// Splash screen controller following SOLID principles
/// Single Responsibility: Manages splash screen logic
/// Open/Closed: Open for extension through composition
/// Dependency Inversion: Depends on abstractions, not concretions
class SplashController extends ChangeNotifier implements SplashStateContract {
  final SplashInitializationContract _initializationService;
  final SplashTimerContract _timerService;
  final SplashNavigationContract _navigationService;

  bool _isLoading = true;
  String? _errorMessage;
  double _progress = 0.0;

  SplashController({
    required SplashInitializationContract initializationService,
    required SplashTimerContract timerService,
    required SplashNavigationContract navigationService,
  }) : _initializationService = initializationService,
       _timerService = timerService,
       _navigationService = navigationService;

  @override
  bool get isLoading => _isLoading;

  @override
  String? get errorMessage => _errorMessage;

  @override
  double get progress => _progress;

  /// Initialize splash screen sequence
  Future<void> initializeSplash() async {
    try {
      _setLoading(true);
      _setProgress(0.0);

      // Start initialization and timer concurrently
      final futures = [_performInitialization(), _startMinimumDisplayTimer()];

      await Future.wait(futures);

      if (_initializationService.isInitialized) {
        await _navigationService.navigateToNextScreen();
      }
    } catch (e) {
      _setError('Failed to initialize app: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _performInitialization() async {
    await _initializationService.initialize();
    _setProgress(0.8);
  }

  Future<void> _startMinimumDisplayTimer() async {
    // Ensure splash screen is displayed for at least 2 seconds
    await _timerService.startTimer(duration: const Duration(seconds: 2));
    _setProgress(1.0);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setProgress(double progress) {
    _progress = progress;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerService.cancelTimer();
    super.dispose();
  }
}
