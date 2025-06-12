import 'dart:async';
import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';
import '../provider/pulse_provider.dart';
import 'pulse_builder.dart' show pulseOfByType;

class PulseListener<T> extends StatefulWidget {
  final Widget child;
  final void Function(BuildContext context, T state) listener;

  const PulseListener({super.key, required this.listener, required this.child});

  @override
  PulseListenerState<T> createState() => PulseListenerState<T>();
}

class PulseListenerState<T> extends State<PulseListener<T>> {
  late PulseBase<T> _pulse;
  StreamSubscription<T>? _subscription;

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
      if (mounted) {
        widget.listener(context, state);
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

class MultiPulseListener extends StatefulWidget {
  final List<Type> pulseTypes;
  final void Function(BuildContext context, List<dynamic> states) listener;
  final Widget child;

  const MultiPulseListener({
    super.key,
    required this.pulseTypes,
    required this.listener,
    required this.child,
  });

  @override
  MultiPulseListenerState createState() => MultiPulseListenerState();
}

class MultiPulseListenerState extends State<MultiPulseListener> {
  late List<PulseBase> _pulses;
  late List<dynamic> _states;
  List<StreamSubscription>? _subscriptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pulses =
        widget.pulseTypes.map((type) => pulseOfByType(context, type)).toList();
    _states = _pulses.map((s) => s.state).toList();
    _subscriptions?.forEach((s) => s.cancel());
    _subscriptions = List.generate(_pulses.length, (i) {
      return _pulses[i].stream.listen((value) {
        _states[i] = value;
        if (mounted) {
          widget.listener(context, List<dynamic>.from(_states));
        }
      });
    });
  }

  @override
  void dispose() {
    if (_subscriptions != null) {
      for (final sub in _subscriptions!) {
        sub.cancel();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
