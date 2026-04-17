# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

This is a **throwaway validation Flutter app** — a test harness for the `vimeo_video_player` package before integrating it into the main **uduX Concerts** production app. The structure deliberately mirrors the production app's clean architecture + BLoC pattern so the player module can be lifted directly once validated.

The build spec lives in `VIMEO_TEST_PROMPT.md` — read it before making any structural changes.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Analyze (must pass with zero errors before considering work done)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Tech Stack

| Concern | Package |
|---|---|
| Player | `vimeo_video_player: ^1.0.3` |
| State management | `flutter_bloc: ^8.1.5` |
| Navigation | `go_router: ^14.0.0` |
| DI | `get_it: ^7.7.0` |
| Responsive sizing | `flutter_screenutil: ^5.9.3` (design size: `390×844`) |
| Equality | `equatable: ^2.0.5` |
| Logging | `logger: ^2.3.0` |

## Architecture

Clean architecture with BLoC, organized under `lib/`:

```
core/
  router/app_router.dart       # GoRouter — AppRoutes.home '/' and AppRoutes.player '/player'
  theme/app_theme.dart         # AppTheme.dark ThemeData; primary=#7B2FBE, bg=#0D0D0D, surface=#1A1A2E
  utils/app_logger.dart        # Wraps logger package; use AppLogger.d/i/w/e() — never print()
features/
  player/
    domain/entities/player_config_entity.dart   # Pure Dart entity — PlayerConfigEntity + PlayerMode enum
    presentation/
      bloc/                    # player_event.dart → player_state.dart → player_bloc.dart
      screens/                 # home_screen.dart, home_screen_widgets.dart, custom_video_entry.dart, player_screen.dart
      widgets/                 # vimeo_player_widget.dart, player_status_bar.dart, player_error_view.dart
```

### BLoC state machine

Linear flow: `PlayerInitial → PlayerLoading → PlayerReady → PlayerEnded / PlayerError`

All events and states are **sealed classes** using Dart 3 pattern matching. `PlayerReady` has a `copyWith` for incremental updates (isPlaying, isFullscreen, position). State transitions guard against out-of-order callbacks (e.g. `_onReady` only fires from `PlayerLoading`).

### Routing

`PlayerScreen` receives a `PlayerConfigEntity` via `state.extra` — no query params. `PlayerScreen` owns the `BlocProvider<PlayerBloc>` and adds `PlayerInitialised(config)` in its creation.

## Code Rules

- **No `print()`** — use `AppLogger` (guarded by `kDebugMode`)
- **Absolute imports only** — `import 'package:udux_concerts_test/...'` (package name is `udux_concerts_test`)
- **200-line file limit per file** — split widgets before hitting it
- **No business logic in widgets** — BLoC handles state transitions
- **`mounted` check** in any async callback touching `context`
- **`const` constructors** wherever possible
- **No `Co-Authored-By` or Claude attribution in commit messages**

## Platform Requirements

- **Android**: `minSdkVersion 24`; `MainActivity` must extend `FlutterFragmentActivity` (required by `flutter_inappwebview` used internally by the player)
- **iOS**: `platform :ios, '14.0'` in Podfile; `NSAllowsArbitraryLoads: true` in `Info.plist`; test on physical device — Vimeo playback does not work on iOS simulators
- Setup steps are documented in `ANDROID_SETUP.md` and `IOS_SETUP.md`

## Theme Tokens

```dart
_primary    = Color(0xFF7B2FBE)  // deep purple
_background = Color(0xFF0D0D0D)  // near-black
_surface    = Color(0xFF1A1A2E)  // elevated card surface
_liveBadge  = Color(0xFFFF3B30)  // red
```

Card borders use `Colors.white.withOpacity(0.08)`.
