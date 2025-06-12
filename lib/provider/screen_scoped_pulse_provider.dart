import 'package:flutter/widgets.dart';
import '../core/pulse_base.dart';

/// Provides a PulseBase only to selected screens (by Type).
class ScreenScopedPulseProvider extends StatelessWidget {
  final PulseBase pulse;
  final List<Type> screenTypes;
  final Widget child;

  const ScreenScopedPulseProvider({
    super.key,
    required this.pulse,
    required this.screenTypes,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _ScreenScope(
      pulse: pulse,
      screenTypes: screenTypes,
      child: child,
    );
  }
}

class _ScreenScope extends InheritedWidget {
  final PulseBase pulse;
  final List<Type> screenTypes;

  const _ScreenScope({
    required this.pulse,
    required this.screenTypes,
    required super.child,
  });

  @override
  bool updateShouldNotify(_ScreenScope oldWidget) =>
      pulse != oldWidget.pulse || screenTypes != oldWidget.screenTypes;
}

/// Multi version for multiple pulses and screen sets
class MultiScreenScopedPulseProvider extends StatelessWidget {
  final List<ScreenScopedProviderEntry> entries;
  final Widget child;

  const MultiScreenScopedPulseProvider({
    super.key,
    required this.entries,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final entry in entries.reversed) {
      tree = ScreenScopedPulseProvider(
        pulse: entry.pulse,
        screenTypes: entry.screenTypes,
        child: tree,
      );
    }
    return tree;
  }
}

class ScreenScopedProviderEntry {
  final PulseBase pulse;
  final List<Type> screenTypes;

  ScreenScopedProviderEntry({
    required this.pulse,
    required this.screenTypes,
  });
}
