# uduX Concerts — Vimeo Player Test Harness

A standalone Flutter validation app for the [`vimeo_video_player`](https://pub.dev/packages/vimeo_video_player) package. This is a **throwaway integration test project** — its sole purpose is to prove out the player architecture before the module is lifted into the main **uduX Concerts** production app.

The folder structure, BLoC pattern, and entity model intentionally mirror the production codebase so the player feature can be extracted and dropped in with minimal changes.

---

## What This Tests

Five scenarios are pre-configured on the home screen:

| # | Scenario | What it validates |
|---|---|---|
| 1 | VOD — public | Load and play a public Vimeo video by ID |
| 2 | VOD — private / unlisted | Play an unlisted video using a `privacyHash` token |
| 3 | Live stream | Load a Vimeo live event ID and play the live feed |
| 4 | Fullscreen + orientation | Enter fullscreen, rotate to landscape, exit back to portrait cleanly |
| 5 | Playback controls | Seek, speed, quality selection via native Vimeo controls |

A **Custom Video ID** form at the bottom of the home screen allows ad-hoc testing of any video without a code change.

---

## Tech Stack

| Concern | Package | Version |
|---|---|---|
| Player | `vimeo_video_player` | `^1.0.3` |
| State management | `flutter_bloc` | `^8.1.5` |
| Navigation | `go_router` | `^14.0.0` |
| Dependency injection | `get_it` | `^7.7.0` |
| Responsive sizing | `flutter_screenutil` | `^5.9.3` |
| Value equality | `equatable` | `^2.0.5` |
| Logging | `logger` | `^2.3.0` |

> **Important:** Use `vimeo_video_player`, **not** `vimeo_player_flutter`. The latter relies on a deprecated Vimeo endpoint.

---

## Architecture

```
lib/
├── main.dart
├── core/
│   ├── router/app_router.dart          # GoRouter config; AppRoutes constants
│   ├── theme/app_theme.dart            # AppTheme.dark ThemeData
│   └── utils/app_logger.dart           # Logger wrapper (never use print())
└── features/
    └── player/
        ├── domain/
        │   └── entities/
        │       └── player_config_entity.dart   # Pure Dart; PlayerMode enum
        └── presentation/
            ├── bloc/
            │   ├── player_event.dart   # Sealed class — all player events
            │   ├── player_state.dart   # Sealed class — Initial/Loading/Ready/Ended/Error
            │   └── player_bloc.dart    # State machine; guards against out-of-order callbacks
            ├── screens/
            │   ├── home_screen.dart
            │   ├── home_screen_widgets.dart    # ScenarioCard + helpers
            │   ├── custom_video_entry.dart     # Ad-hoc video ID form
            │   └── player_screen.dart          # Owns BlocProvider + orientation lifecycle
            └── widgets/
                ├── vimeo_player_widget.dart    # Renders player or error/ended overlays
                ├── player_status_bar.dart      # State indicator + position counter
                └── player_error_view.dart      # PlayerErrorView + PlayerEndedView
```

### BLoC State Machine

The player state flows linearly:

```
PlayerInitial → PlayerLoading → PlayerReady ──► PlayerEnded
                                    │
                                    └──────────► PlayerError
```

All events and states are **sealed classes** (Dart 3). `PlayerReady` carries `isPlaying`, `isFullscreen`, and `position`, updated via `copyWith`. Handlers guard against out-of-order native callbacks (e.g. `onReady` is ignored unless the current state is `PlayerLoading`).

### Routing

`PlayerScreen` receives a `PlayerConfigEntity` via `GoRouter`'s `state.extra` — no query parameters. The screen owns the `BlocProvider<PlayerBloc>` and immediately dispatches `PlayerInitialised(config)` on creation.

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.11.4` with Dart SDK `^3.11.4`
- For iOS: physical device required — Vimeo playback does not work on the iOS simulator

### Run

```bash
flutter pub get
flutter run
```

### Analyze & Test

```bash
flutter analyze          # must pass with zero errors
flutter test             # widget tests
flutter test test/widget_test.dart   # single file
```

---

## Platform Setup

### Android

> See `ANDROID_SETUP.md` for the full checklist.

Key requirements:
- `minSdkVersion 24`
- `MainActivity` must extend `FlutterFragmentActivity` (required by `flutter_inappwebview`, which the player uses internally)
- `INTERNET` permission in `AndroidManifest.xml`

### iOS

> See `IOS_SETUP.md` for the full checklist.

Key requirements:
- `platform :ios, '14.0'` in `Podfile`
- `NSAllowsArbitraryLoads: true` in `Info.plist` (Vimeo streams require arbitrary network access)
- Must test on a physical device

---

## Theme

Dark-only. Tokens defined in `AppTheme`:

| Token | Colour | Use |
|---|---|---|
| Primary | `#7B2FBE` | Buttons, pills, icon tints |
| Background | `#0D0D0D` | Scaffold background |
| Surface | `#1A1A2E` | Elevated cards |
| Live badge | `#FF3B30` | LIVE indicator dot and pill |

Card borders: `Colors.white.withOpacity(0.08)`
Responsive base size: `390×844` (iPhone 14)

---

## Code Conventions

- **No `print()`** — use `AppLogger.d/i/w/e()`, guarded by `kDebugMode`
- **Absolute imports only** — `import 'package:udux_concerts_test/...'`
- **200-line file limit** — split widgets into separate files before hitting it
- **No business logic in widgets** — BLoC handles all state transitions; widgets only render and dispatch events
- **`mounted` check** before any `context` usage in async callbacks
- **`const` constructors** wherever possible
- **No `Co-Authored-By` or tool attribution** in commit messages

---

## Replacing Placeholder Values

Before testing private or live scenarios, swap these values in `home_screen.dart`:

| Placeholder | Replace with |
|---|---|
| `'replace_with_real_hash'` | The `privacyHash` from a real unlisted Vimeo video URL |
| `'replace_with_live_event_id'` | A Vimeo live event video ID |

---

## Acceptance Checklist

- [ ] `flutter pub get` succeeds with zero warnings
- [ ] `flutter analyze` passes with zero errors
- [ ] All files are ≤ 200 lines
- [ ] Home screen shows 4 scenario cards + custom entry form
- [ ] Tapping a scenario navigates to the player screen (portrait)
- [ ] Player auto-starts on entry
- [ ] Status bar reflects state changes: loading → ready → playing → paused → ended
- [ ] VOD position counter updates during playback
- [ ] Fullscreen rotates to landscape and hides AppBar; exiting returns to portrait
- [ ] Custom entry form accepts a private video ID + hash
- [ ] Back-navigation from player restores portrait-only orientation lock
