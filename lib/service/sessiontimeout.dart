import 'dart:async';
import 'dart:ui';

class SessionManager {
  Timer? _idleTimer;
  Timer? _warningTimer;

  final Duration idleThreshold = const Duration(minutes: 3);
  final Duration warningBefore = const Duration(minutes: 1);

  void resetTimers({
    required VoidCallback onWarning,
    required VoidCallback onTimeout,
  }) {
    _idleTimer?.cancel();
    _warningTimer?.cancel();

    // Warning first (idleThreshold - warningBefore)
    _warningTimer = Timer(idleThreshold - warningBefore, onWarning);

    // Final timeout
    _idleTimer = Timer(idleThreshold, onTimeout);
  }

  void dispose() {
    _idleTimer?.cancel();
    _warningTimer?.cancel();
  }
}
