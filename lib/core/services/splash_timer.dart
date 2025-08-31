import 'dart:async';
import '../contracts/splash_contract.dart';

/// Implementation of splash timer functionality
/// Following Single Responsibility Principle (SRP)
class SplashTimer implements SplashTimerContract {
  Timer? _timer;

  @override
  Future<void> startTimer({required Duration duration}) async {
    final completer = Completer<void>();

    _timer = Timer(duration, () {
      completer.complete();
    });

    return completer.future;
  }

  @override
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }
}
