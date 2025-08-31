/// Abstract contracts for splash screen functionality
/// Following Interface Segregation Principle (ISP)

/// Contract for splash screen navigation behavior
abstract class SplashNavigationContract {
  Future<void> navigateToNextScreen();
}

/// Contract for splash screen initialization
abstract class SplashInitializationContract {
  Future<void> initialize();
  bool get isInitialized;
}

/// Contract for splash screen timer functionality
abstract class SplashTimerContract {
  Future<void> startTimer({required Duration duration});
  void cancelTimer();
}

/// Contract for splash screen state management
abstract class SplashStateContract {
  bool get isLoading;
  String? get errorMessage;
  double get progress;
}
