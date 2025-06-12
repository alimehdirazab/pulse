import 'dart:async';
import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';
import '../provider/pulse_provider.dart';

// PulseBuilder: Rebuilds when state changes.
class PulseBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state) builder;

  const PulseBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    return StreamBuilder<T>(
      stream: pulse.stream,
      initialData: pulse.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? pulse.state;
        return builder(context, state);
      },
    );
  }
}

// MultiPulseBuilder: Rebuilds when any of the provided pulses change.
class MultiPulseBuilder extends StatelessWidget {
  final List<Type> pulseTypes;
  final Widget Function(BuildContext context, List<dynamic> states) builder;

  const MultiPulseBuilder({
    super.key,
    required this.pulseTypes,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final pulses =
        pulseTypes.map((type) => pulseOfByType(context, type)).toList();

    return _MultiStreamBuilder(
      pulses: pulses,
      builder: builder,
    );
  }
}

// Helper widget for combining multiple streams.
class _MultiStreamBuilder extends StatefulWidget {
  final List<PulseBase> pulses;
  final Widget Function(BuildContext, List<dynamic>) builder;

  const _MultiStreamBuilder({
    required this.pulses,
    required this.builder,
  });

  @override
  State<_MultiStreamBuilder> createState() => _MultiStreamBuilderState();
}

class _MultiStreamBuilderState extends State<_MultiStreamBuilder> {
  late List<dynamic> _states;
  late List<StreamSubscription> _subscriptions;

  @override
  void initState() {
    super.initState();
    _states = widget.pulses.map((s) => s.state).toList();
    _subscriptions = List.generate(widget.pulses.length, (i) {
      return widget.pulses[i].stream.listen((value) {
        setState(() {
          _states[i] = value;
        });
      });
    });
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _states);
  }
}

// PulseSelector: Only rebuilds when selected value changes.
class PulseSelector<T, S> extends StatelessWidget {
  final S Function(T state) selector;
  final Widget Function(BuildContext context, S selected) builder;
  const PulseSelector({
    super.key,
    required this.selector,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    return StreamBuilder<T>(
      stream: pulse.stream,
      initialData: pulse.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? pulse.state;
        final selected = selector(state);
        return builder(context, selected);
      },
    );
  }
}

// PulseBlocBuilder: Like PulseBuilder but allows building based on previous and current state.
class PulseBlocBuilder<T> extends StatelessWidget {
  final Widget Function(BuildContext context, T state, T? previousState)
      builder;

  const PulseBlocBuilder({Key? key, required this.builder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    return _PulseBlocStreamBuilder<T>(
      pulse: pulse,
      builder: builder,
    );
  }
}

class _PulseBlocStreamBuilder<T> extends StatefulWidget {
  final PulseBase<T> pulse;
  final Widget Function(BuildContext, T, T?) builder;

  const _PulseBlocStreamBuilder({
    Key? key,
    required this.pulse,
    required this.builder,
  }) : super(key: key);

  @override
  State<_PulseBlocStreamBuilder<T>> createState() =>
      _PulseBlocStreamBuilderState<T>();
}

class _PulseBlocStreamBuilderState<T>
    extends State<_PulseBlocStreamBuilder<T>> {
  T? _previous;
  late T _current;
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _current = widget.pulse.state;
    _subscription = widget.pulse.stream.listen((state) {
      setState(() {
        _previous = _current;
        _current = state;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _current, _previous);
  }
}

// PulseDebounceBuilder: Unique feature - only rebuilds after a debounce duration.
class PulseDebounceBuilder<T> extends StatefulWidget {
  final Duration debounce;
  final Widget Function(BuildContext context, T state) builder;

  const PulseDebounceBuilder({
    Key? key,
    required this.debounce,
    required this.builder,
  }) : super(key: key);

  @override
  State<PulseDebounceBuilder<T>> createState() =>
      _PulseDebounceBuilderState<T>();
}

class _PulseDebounceBuilderState<T> extends State<PulseDebounceBuilder<T>> {
  late PulseBase<T> _pulse;
  T? _state;
  StreamSubscription<T>? _subscription;
  Timer? _debounceTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    _pulse = pulse;
    _state = _pulse.state;
    _subscription?.cancel();
    _subscription = _pulse.stream.listen((state) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounce, () {
        if (mounted) setState(() => _state = state);
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _state as T);
  }
}

// PulseWatch: Unique feature - exposes a ValueNotifier for state, for easy integration with ValueListenableBuilder.
class PulseWatch<T> extends StatefulWidget {
  final Widget Function(BuildContext context, ValueNotifier<T> notifier)
      builder;

  const PulseWatch({Key? key, required this.builder}) : super(key: key);

  @override
  State<PulseWatch<T>> createState() => _PulseWatchState<T>();
}

class _PulseWatchState<T> extends State<PulseWatch<T>> {
  late PulseBase<T> _pulse;
  late ValueNotifier<T> _notifier;
  StreamSubscription<T>? _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final pulse = PulseProvider.of<T>(context);
    if (pulse is! PulseBase<T>) {
      throw FlutterError('PulseProvider.of<$T> did not return a PulseBase<$T>');
    }
    _pulse = pulse;
    _notifier = ValueNotifier<T>(_pulse.state);
    _subscription?.cancel();
    _subscription = _pulse.stream.listen((state) {
      _notifier.value = state;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _notifier);
  }
}

// Utility to get PulseBase by type from context (for MultiPulseBuilder)
PulseBase<dynamic> pulseOfByType(BuildContext context, Type type) {
  PulseBase? found;
  void visitor(Element element) {
    if (element.widget is PulseProvider) {
      final provider = element.widget as PulseProvider;
      if (provider.pulse.runtimeType == type) {
        found = provider.pulse;
      }
    }
    if (found == null) element.visitChildElements(visitor);
  }

  context.visitChildElements(visitor);
  if (found == null) {
    throw FlutterError('No PulseProvider<$type> found in context');
  }
  return found!;
}
