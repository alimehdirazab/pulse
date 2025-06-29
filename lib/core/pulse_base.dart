import 'dart:async';
import 'package:meta/meta.dart';

// Listener typedef for Pulse
typedef PulseListener<T> = void Function(T state);

// Base class for all Pulse state managers
abstract class PulseBase<T> {
  PulseBase(this._state);

  T _state;
  final _controller = StreamController<T>.broadcast();
  late final T _initialState = _state;

  T get state => _state;

  Stream<T> get stream => _controller.stream;

  // Push a new state to listeners
  void push(T state) {
    if (_state == state) return;
    _state = state;
    _controller.add(_state);
    onPush(_state);
  }

  // Called after every push, can be overridden for side effects/logging
  @protected
  void onPush(T state) {}

  // Listen to state changes
  StreamSubscription<T> listen(PulseListener<T> listener) {
    return stream.listen(listener);
  }

  // Synchronously update state (for advanced use)
  void setState(T Function(T current) updater) {
    push(updater(_state));
  }

  // Reset state to initial (if supported)
  void reset() {
    push(_initialState);
  }

  // Close the stream controller
  void close() {
    _controller.close();
    onClose();
  }

  // Called after close, can be overridden for cleanup
  @protected
  void onClose() {}
}
