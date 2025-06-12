import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';

class PulseProvider<T> extends InheritedWidget {
  final PulseBase<T> pulse;

  const PulseProvider({
    super.key,
    required super.child,
    required this.pulse,
  });

  static T of<T>(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<PulseProvider<T>>();
    assert(provider != null, 'No PulseProvider<$T> found in context');
    return provider!.pulse as T;
  }

  @override
  bool updateShouldNotify(PulseProvider<T> oldWidget) =>
      pulse != oldWidget.pulse;
}

class MultiPulseProvider extends StatelessWidget {
  final List<PulseProvider> providers;
  final Widget child;

  const MultiPulseProvider({
    super.key,
    required this.providers,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final provider in providers.reversed) {
      tree = provider.copyWith(child: tree);
    }
    return tree;
  }
}

// Extension to allow copying PulseProvider with a new child.
extension _PulseProviderCopy on PulseProvider {
  PulseProvider copyWith({required Widget child}) {
    return PulseProvider(
      pulse: pulse,
      child: child,
    );
  }
}
