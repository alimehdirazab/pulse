## 0.0.1

- Initial release of pulse_statex: a modern, flexible, and powerful state management package for Flutter.
- Features:
  - PulseBase: core state management class.
  - PulseProvider / MultiPulseProvider: provide state to the widget tree.
  - PulseBuilder / MultiPulseBuilder: rebuild widgets on state changes.
  - PulseSelector: rebuild only when selected part of state changes.
  - PulseBlocBuilder: access current and previous state.
  - PulseConsumer: combines builder and listener.
  - PulseListener / MultiPulseListener: listen to state changes and trigger side effects.
  - PulseEffect: run a side effect only once when a condition is met.
  - PulseDebounceBuilder: debounced UI rebuilds.
  - PulseWatch: exposes ValueNotifier for state.
  - ScreenScopedPulseProvider: provide state only to selected screens/types.
  - Type-safe, null-safe, and extensible API.

  ## 0.0.2

  - Minor bug fixes.