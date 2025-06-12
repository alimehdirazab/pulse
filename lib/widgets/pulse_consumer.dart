import 'dart:async';
import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';
import '../provider/pulse_provider.dart';
import 'pulse_builder.dart';

class PulseConsumer<T> extends StatefulWidget {
  final Widget Function(BuildContext context, T state) builder;
  final void Function(BuildContext context, T state)? listener;

  const PulseConsumer({super.key, required this.builder, this.listener});

  @override
  PulseConsumerState<T> createState() => PulseConsumerState<T>();
}

class PulseConsumerState<T> extends State<PulseConsumer<T>> {
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
    if (widget.listener != null) {
      _subscription = _pulse.stream.listen((state) {
        if (mounted) {
          widget.listener!(context, state);
        }
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PulseBuilder<T>(builder: widget.builder);
  }
}
