# Vimeo Player Test App — Claude Code Prompt

## Goal

Build a small standalone Flutter app that acts as a **test harness for the `vimeo_video_player` package**. This is a throwaway validation project used to prove out the player architecture before integrating it into the main **uduX Concerts** app. The structure must mirror the main app's clean architecture + BLoC pattern so the player module can be lifted directly into production once validated.

---

## What to Test

The test app must let me exercise each of these scenarios without code changes:

1. **VOD playback** — load a public Vimeo video by ID and play it
2. **Live stream playback** — load a Vimeo live event ID and play the live feed
3. **Private video with playback token** — play an unlisted Vimeo video using a `privacyHash`
4. **Fullscreen + orientation lock** — enter fullscreen, rotate to landscape, exit back to portrait cleanly
5. **Playback controls** — seek, playback speed, quality selection (whatever the package exposes through its native Vimeo controls)

All five must be reachable from a single home screen with pre-configured scenario cards, plus a "custom video ID" form for ad-hoc testing.

---

## Tech Stack (fixed)

| Concern | Package |
|---|---|
| Player | `vimeo_video_player: ^1.0.3` (NOT `vimeo_player_flutter` — that one uses a deprecated endpoint) |
| State management | `flutter_bloc: ^8.1.5` |
| Navigation | `go_router: ^14.0.0` |
| DI | `get_it: ^7.7.0` |
| Responsive sizing | `flutter_screenutil: ^5.9.3` |
| Equality | `equatable: ^2.0.5` |
| Logging | `logger: ^2.3.0` |

**Dart SDK**: `>=3.0.0 <4.0.0` (sealed classes + pattern matching required).

---

## Project Setup

The Flutter project has already been created with:

```bash
flutter create --org ng.groove --project-name vimeo_test_app --platforms ios,android vimeo_test_app
```

Package name in imports is `vimeo_test_app`. Use absolute imports everywhere — never relative `../`.

---

## Folder Structure

```
lib/
├── main.dart
├── core/
│   ├── router/
│   │   └── app_router.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── app_logger.dart
└── features/
    └── player/
        ├── domain/
        │   └── entities/
        │       └── player_config_entity.dart
        └── presentation/
            ├── bloc/
            │   ├── player_bloc.dart
            │   ├── player_event.dart
            │   └── player_state.dart
            ├── screens/
            │   ├── home_screen.dart
            │   ├── home_screen_widgets.dart   # ScenarioCard + private helpers
            │   ├── custom_video_entry.dart    # custom ID form
            │   └── player_screen.dart
            └── widgets/
                ├── vimeo_player_widget.dart
                ├── player_status_bar.dart
                └── player_error_view.dart     # PlayerErrorView + PlayerEndedView
```

**Hard limit: 200 lines per file.** Split widgets into separate files before you approach the limit.

---

## Theme (Dark by Default)

The main app is dark-themed. Use these tokens in `AppTheme`:

- `_primary` = `Color(0xFF7B2FBE)` — deep purple
- `_background` = `Color(0xFF0D0D0D)` — near-black
- `_surface` = `Color(0xFF1A1A2E)` — elevated card surface
- `_liveBadge` = `Color(0xFFFF3B30)` — red

Expose `AppTheme.dark` as a `ThemeData` and `AppTheme.liveBadgeColor` as a static getter. Card borders should use `Colors.white.withOpacity(0.08)`.

---

## Domain

### `PlayerConfigEntity`

A pure Dart entity (no Flutter imports) that encodes everything the player needs:

```dart
enum PlayerMode { vod, live }

class PlayerConfigEntity extends Equatable {
  final String videoId;
  final PlayerMode mode;
  final String? privacyHash;  // for private/unlisted videos
  final String label;

  const PlayerConfigEntity({
    required this.videoId,
    required this.mode,
    required this.label,
    this.privacyHash,
  });

  bool get isLive => mode == PlayerMode.live;
  bool get isPrivate => privacyHash != null && privacyHash!.isNotEmpty;

  @override
  List<Object?> get props => [videoId, mode, privacyHash, label];
}
```

---

## BLoC — Sealed Classes

The player flow is strictly linear (Initial → Loading → Ready → Ended/Error), so use **sealed classes**, not single-state.

### `PlayerEvent` — sealed

All events as `final class` subclasses of `sealed class PlayerEvent extends Equatable`:

- `PlayerInitialised(PlayerConfigEntity config)`
- `PlayerReadyReceived()` — fired from `onReady` callback
- `PlayerStarted()` — fired from `onPlay`
- `PlayerPaused()` — fired from `onPause`
- `PlayerFinished()` — fired from `onFinish`
- `PlayerSeeked()` — fired from `onSeek`
- `PlayerFullscreenEntered()` — fired from `onEnterFullscreen`
- `PlayerFullscreenExited()` — fired from `onExitFullscreen`
- `PlayerErrorOccurred(String message)` — fired from `onInAppWebViewReceivedError`
- `PlayerPositionUpdated(Duration position)` — fired from `onVideoPosition`

### `PlayerState` — sealed

- `PlayerInitial()`
- `PlayerLoading(PlayerConfigEntity config)`
- `PlayerReady({required PlayerConfigEntity config, bool isPlaying, bool isFullscreen, Duration position})` — with `copyWith`
- `PlayerEnded(PlayerConfigEntity config)`
- `PlayerError(String message)`

### `PlayerBloc`

- Starts in `PlayerInitial()`
- `_onInitialised` → emit `PlayerLoading(config)` and log
- `_onReady` → only transition if current state is `PlayerLoading` → emit `PlayerReady`
- `_onStarted/_onPaused/_onFullscreen*/_onPositionUpdated` → only mutate if state is `PlayerReady`, use `copyWith`
- `_onFinished` → `PlayerEnded`
- `_onError` → `PlayerError`
- Every handler calls `AppLogger.d/i/e()` — no raw `print()`

---

## Widgets

### `VimeoPlayerWidget` (core)

The main player widget. Must be wrapped in a `BlocProvider<PlayerBloc>` by the caller (handled by `PlayerScreen`).

Render based on state:
- `PlayerError(message)` → `PlayerErrorView` with retry button that re-adds `PlayerInitialised(config)`
- `PlayerEnded(config)` → `PlayerEndedView` with replay button
- default → the actual `VimeoVideoPlayer` widget

The `VimeoVideoPlayer` constructor takes (from the package):
```dart
VimeoVideoPlayer(
  videoId: config.videoId,
  privacyHash: config.privacyHash,
  isAutoPlay: true,
  showControls: true,
  showTitle: false,
  showByline: false,
  enableDNT: true,
  backgroundColor: Colors.black,
  onReady: () => bloc.add(const PlayerReadyReceived()),
  onPlay: () => bloc.add(const PlayerStarted()),
  onPause: () => bloc.add(const PlayerPaused()),
  onFinish: () => bloc.add(const PlayerFinished()),
  onSeek: () => bloc.add(const PlayerSeeked()),
  onEnterFullscreen: (_) => bloc.add(const PlayerFullscreenEntered()),
  onExitFullscreen: (_) => bloc.add(const PlayerFullscreenExited()),
  onInAppWebViewReceivedError: (_, __, error) =>
      bloc.add(PlayerErrorOccurred(error?.description ?? 'Playback error')),
  onVideoPosition: (position) =>
      bloc.add(PlayerPositionUpdated(Duration(seconds: position.toInt()))),
)
```

### `PlayerStatusBar`

A horizontal bar under the player showing:
- State indicator dot (grey/loading spinner/live red dot/green playing dot/red error)
- Event label
- Sub-label: `'Loading…'` / `'Playing'` / `'Fullscreen'` / `'Ready'` / `'Ended'` / error message
- For VOD only: current playback position formatted as `mm:ss` or `h:mm:ss`, right-aligned, monospace font

Must use a `BlocBuilder<PlayerBloc, PlayerState>` and a Dart 3 switch expression to derive the UI from state.

### `PlayerErrorView` + `PlayerEndedView`

Both live in `player_error_view.dart`. Centered content on black background:
- Error: red `error_outline` icon, "Playback error" title, error message, "Retry" elevated button
- Ended: green `check_circle_outline` icon, "Video ended" title, event label, "Watch again" button

---

## Screens

### `HomeScreen`

Test harness entry point. Portrait only.

Hard-coded scenarios list as a static `const _scenarios` containing 4 `PlayerConfigEntity` instances:
- VOD public (use a known working Vimeo sample ID like `76979871`)
- VOD private — placeholder `'replace_with_real_hash'` for the hash; user will swap in real values
- Live — placeholder `'replace_with_live_event_id'` for the videoId
- A second VOD public (e.g. `148751763`) for regression comparison

Layout:
- AppBar title "Vimeo Player — Test Harness"
- Section header "TEST SCENARIOS" (uppercase, letterspaced, muted)
- List of `ScenarioCard` widgets, each tappable → `context.push(AppRoutes.player, extra: config)`
- Section header "CUSTOM VIDEO ID"
- `CustomVideoEntry` widget

### `ScenarioCard` (in `home_screen_widgets.dart`)

Row with:
- 44×44 rounded icon container — `sensors` icon for live (red tint), `lock_outline` for private VOD, `ondemand_video` for public VOD (purple tint)
- Label + metadata row: mode pill (VOD teal / LIVE red), PRIVATE pill (purple) if applicable, video ID in monospace
- Chevron-equivalent: `play_circle_outline` icon on the right

### `CustomVideoEntry` (in `custom_video_entry.dart` — separate file)

Stateful widget with:
- VOD / Live mode toggle (two pill chips)
- Video ID `TextField` (number keyboard)
- Checkbox row: "Private / unlisted video (add privacy hash)"
- Conditional privacy hash `TextField` when checkbox is on
- Full-width "Launch player" elevated button

On launch: validate the ID is non-empty (show SnackBar if empty), build a `PlayerConfigEntity`, and push the player route.

Include a private `extension on String { String? get nullIfEmpty => isEmpty ? null : this; }` at the bottom.

### `PlayerScreen`

Stateful widget. Receives `PlayerConfigEntity` as route extra.

- `initState`: unlock orientations to allow landscape
  ```dart
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  ```
- `dispose`: lock back to portrait only
- `build`: wraps body in `BlocProvider(create: (_) => PlayerBloc()..add(PlayerInitialised(config)), child: _PlayerScreenBody(...))`

`_PlayerScreenBody` uses a `BlocBuilder<PlayerBloc, PlayerState>` to read whether the player is in fullscreen, and:
- Hides the AppBar when `isFullscreen`
- Shows a `LIVE` badge in the AppBar actions when `config.isLive`
- Lays out body as a Column:
  1. `AspectRatio(aspectRatio: 16/9, child: VimeoPlayerWidget(config: config))`
  2. When not fullscreen: `PlayerStatusBar` + `_DebugInfoCard` showing video ID, mode, private flag, privacy hash

`_DebugInfoCard` is a local private widget with a "DEBUG INFO" label header and `label: value` rows.

---

## Routing

`AppRoutes` constants:
```dart
class AppRoutes {
  static const home = '/';
  static const player = '/player';
}
```

GoRouter with two routes. Player route reads `state.extra as PlayerConfigEntity`.

---

## `main.dart`

- `WidgetsFlutterBinding.ensureInitialized()`
- Lock to portrait on app start (`SystemChrome.setPreferredOrientations`)
- Transparent status bar with light icons
- Wrap app in `ScreenUtilInit(designSize: Size(390, 844))` — iPhone 14 base
- Return `MaterialApp.router(theme: AppTheme.dark, routerConfig: appRouter, debugShowCheckedModeBanner: false)`

---

## Platform Config

### Android
- `android/app/src/main/kotlin/.../MainActivity.kt`: change `FlutterActivity` → `FlutterFragmentActivity` (required by `flutter_inappwebview`, which the player uses internally)
- `android/app/build.gradle`: `minSdkVersion 24`
- `AndroidManifest.xml`: `<uses-permission android:name="android.permission.INTERNET"/>` (usually already there)

### iOS
- `ios/Runner/Info.plist`: add
  ```xml
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
  </dict>
  ```
- `ios/Podfile`: `platform :ios, '14.0'`
- Must test on physical device — Vimeo playback doesn't work on iOS simulators

Create `ANDROID_SETUP.md` and `IOS_SETUP.md` in the project root documenting these steps.

---

## Code Rules

1. **No `print()`** — use `AppLogger.d/i/w/e()`, guarded by `kDebugMode`
2. **Sealed classes + Dart 3 pattern matching** for all BLoC events/states
3. **`mounted` check** in any async callback that touches `context`
4. **Absolute imports only** — `import 'package:vimeo_test_app/...'`
5. **200-line file limit** — split before hitting it
6. **No business logic in widgets** — BLoC handles state transitions, widgets only render + dispatch
7. **Const constructors** wherever possible
8. **No `Co-Authored-By` or Claude attribution in any commit message**

---

## Acceptance — What "Done" Looks Like

- [ ] `flutter pub get` succeeds with zero warnings
- [ ] `flutter analyze` passes with zero errors
- [ ] Every file is ≤ 200 lines
- [ ] Home screen shows 4 scenario cards + a custom entry form
- [ ] Tapping a scenario navigates to player screen, portrait
- [ ] Player starts automatically on entry (`isAutoPlay: true`)
- [ ] Status bar below player reflects state changes (loading → ready → playing → paused → ended)
- [ ] Position counter updates during VOD playback
- [ ] Tapping Vimeo's native fullscreen control rotates to landscape and hides the AppBar
- [ ] Exiting fullscreen returns to portrait cleanly
- [ ] Custom video entry accepts a private video ID + hash and plays it
- [ ] Back-navigating from player restores portrait-only orientation lock
- [ ] No raw `TextField`/`ElevatedButton` in the error/ended views — those use the app's styled components from `AppTheme`

---

## Build Order

1. `pubspec.yaml` with all dependencies
2. `core/utils/app_logger.dart`
3. `core/theme/app_theme.dart`
4. `features/player/domain/entities/player_config_entity.dart`
5. `features/player/presentation/bloc/` (event → state → bloc in that order)
6. `features/player/presentation/widgets/player_error_view.dart` (both views in one file)
7. `features/player/presentation/widgets/player_status_bar.dart`
8. `features/player/presentation/widgets/vimeo_player_widget.dart`
9. `features/player/presentation/screens/player_screen.dart`
10. `features/player/presentation/screens/home_screen_widgets.dart`
11. `features/player/presentation/screens/custom_video_entry.dart`
12. `features/player/presentation/screens/home_screen.dart`
13. `core/router/app_router.dart`
14. `main.dart`
15. `ANDROID_SETUP.md` + `IOS_SETUP.md`
16. Platform config edits (`MainActivity.kt`, `Info.plist`, `Podfile`)
