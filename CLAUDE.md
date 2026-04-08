# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

Flutter plugin that wraps native Lottie animation libraries (lottie-ios and
lottie-android) to render animations using platform-specific implementations.
Forked from flutter_lottie.

## Common Commands

```bash
# Install melos (if not installed)
dart pub global activate melos

# Bootstrap packages
melos bootstrap

# Run analysis
melos run analyze

# Check formatting (CI uses this)
melos run format:check:dart

# Format code
melos run format:dart
```

## Architecture

### Platform Channel Communication

The plugin uses Flutter's Method Channel and Event Channel pattern:

- **Method Channels** (`de.lotum/lottie_native_[id]`): Send commands to native
  (play, pause, stop, etc.)
- **Event Channels** (`de.lotum/lottie_native_state_[id]`): Stream animation
  state changes (loaded, started, finished, cancelled)

Each LottieView instance gets unique channels using its viewId.

### Key Components

**Dart (lib/src/):**

- `LottieView` - Widget with factory constructors: `fromURL`, `fromAsset`,
  `fromJson`
- `LottieController` - Animation lifecycle management, exposes play/pause/stop
  and state streams
- `LOTValue` - Type system for dynamic animation properties (LOTColorValue,
  LOTOpacityValue)

**Android (android/src/main/kotlin/):**

- `LottieNativePlugin` - Plugin entry point
- `LottieView` - Wraps LottieAnimationView, handles MethodCall routing

**iOS (ios/Classes/):**

- `LottieNativePlugin` - Plugin entry point
- `LottieView` - Wraps LottieAnimationView, implements FlutterStreamHandler

### Native Dependencies

- Android: `com.airbnb.android:lottie`
- iOS: `lottie-ios`

## Monorepo Structure

Uses Melos to manage root plugin + example app. The example app in `example/`
contains sample animations and demonstrates the API.
