import 'dart:async';

// Application-wide event broadcasting.
//
// Use this only for genuinely cross-cutting signals that no single owner can
// deliver (auth state changed, connectivity dropped, a table changed remotely).
// Feature-to-feature calls should be direct and typed, not routed through here.
class EventBus {
  final StreamController<AppEvent> _controller =
      StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  // Typed subscription helper: eventBus.on<SessionEndedEvent>().listen(...)
  Stream<T> on<T extends AppEvent>() => stream.where((e) => e is T).cast<T>();

  void fire(AppEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  void dispose() {
    _controller.close();
  }
}

// Base class for all events.
abstract class AppEvent {
  const AppEvent();
}

// Fired when session-scoped state should be discarded.
class SessionEndedEvent extends AppEvent {
  const SessionEndedEvent();
}
