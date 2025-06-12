import 'dart:async';
import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';
import '../provider/pulse_provider.dart';

class PulseEffect<T> extends StatefulWidget {
  final bool Function(T state) condition;
  final void Function(BuildContext context, T state) effect;
  final Widget child;

  const PulseEffect({
    super.key,
    required this.condition,
    required this.effect,
    required this.child,
  });

  @override
  PulseEffectState<T> createState() => PulseEffectState<T>();
}

class PulseEffectState<T> extends State<PulseEffect<T>> {
  late PulseBase<T> _pulse;
  StreamSubscription<T>? _subscription;
  bool _hasRun = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription?.cancel();
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    _pulse = pulse;
    _subscription = _pulse.stream.listen((state) {
      if (!_hasRun && widget.condition(state)) {
        _hasRun = true;
        if (mounted) {
          widget.effect(context, state);
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
