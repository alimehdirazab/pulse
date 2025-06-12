<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# PulseStateX

PulseStateX is a powerful, flexible, and modern state management solution for Flutter. Inspired by Cubit and other state management patterns, PulseStateX provides a robust API for managing, reacting to, and providing state throughout your Flutter app. PulseStateX is designed for simplicity, performance, and scalability, and introduces unique features for advanced use cases.

---

## Features

- **PulseBase**: Core class for state management with a simple, extensible API.
- **PulseProvider / MultiPulseProvider**: Provide state to your widget tree, supporting both single and multiple providers.
- **PulseBuilder / MultiPulseBuilder**: Rebuild widgets in response to state changes, supporting both single and multiple states.
- **PulseSelector**: Efficiently rebuild only when a selected part of the state changes.
- **PulseBlocBuilder**: Access both current and previous state in your builder.
- **PulseConsumer**: Combines builder and listener for state and side effects.
- **PulseListener / MultiPulseListener**: Listen to state changes and trigger side effects.
- **PulseEffect**: Run a side effect only once when a condition is met.
- **PulseDebounceBuilder**: Debounced UI rebuilds for performance-sensitive UIs.
- **PulseWatch**: Exposes a ValueNotifier for state, enabling integration with ValueListenableBuilder.
- **ScreenScopedPulseProvider**: Provide state only to selected screens/types.
- **Type-safe, null-safe, and easy to extend.**

---

## Getting started

Add PulseStateX to your `pubspec.yaml`:

```yaml
dependencies:
  pulse_statex: ^0.0.1
```

Import PulseStateX in your Dart code:

```dart
import 'package:pulse_statex/pulse_statex.dart';
```

---

## Usage

### 1. Create your Pulse

```dart
class CounterPulse extends PulseBase<int> {
  CounterPulse() : super(0);

  void increment() => push(state + 1);
  void decrement() => push(state - 1);
}
```

### 2. Provide your Pulse

```dart
PulseProvider(
  pulse: CounterPulse(),
  child: MyApp(),
)
```

Or for multiple:

```dart
MultiPulseProvider(
  providers: [
    PulseProvider(pulse: CounterPulse(), child: ...),
    // Add more providers here
  ],
  child: MyApp(),
)
```

### 3. Use Pulse in your widgets

```dart
PulseBuilder<int>(
  builder: (context, state) {
    return Text('Value: $state');
  },
)
```

### 4. Listen for changes

```dart
PulseListener<int>(
  listener: (context, state) {
    // Do something when state changes
  },
  child: ...,
)
```

### 5. Use advanced features

- **PulseSelector** for partial rebuilds
- **PulseBlocBuilder** for previous/current state
- **PulseEffect** for one-time side effects
- **ScreenScopedPulseProvider** for screen-specific state

---

## Example

```dart
class CounterPulse extends PulseBase<int> {
  CounterPulse() : super(0);

  void increment() => push(state + 1);
  void decrement() => push(state - 1);
}

void main() {
  runApp(
    PulseProvider(
      pulse: CounterPulse(),
      child: MaterialApp(
        home: Scaffold(
          body: PulseBuilder<int>(
            builder: (context, state) => Text('Counter: $state'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () =>
                PulseProvider.of<CounterPulse>(context).increment(),
            child: Icon(Icons.add),
          ),
        ),
      ),
    ),
  );
}
```

---

## Additional information

- **Documentation**: See the API docs for details on each class and method.
- **Contributing**: PRs and issues are welcome! Please open an issue or submit a pull request on GitHub.
- **License**: MIT

---

PulseStateX is designed to be the heartbeat of your Flutter app's state management.  
Happy coding!
