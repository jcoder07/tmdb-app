# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Validation Commands

Use the Xcode MCP tools — do not use `xcodebuild` directly.

- **Build**: `BuildProject`
- **Quick diagnostics** (faster than a full build): `XcodeRefreshCodeIssuesInFile` — catches type errors, missing imports, unresolved identifiers within seconds
- **Run all tests**: `RunAllTests`
- **Run specific tests**: `RunSomeTests`

Always run `XcodeRefreshCodeIssuesInFile` on every file you edit before declaring work done.

## API Key Setup

The TMDB API key is **not** in source control. It lives in `tmdb-app/Config.xcconfig` (gitignored). Copy `Config.xcconfig.example` to `Config.xcconfig` and fill in the key. The xcconfig feeds `Info.plist`, which the app reads at runtime:

```swift
Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
```

## Architecture

### Navigation (UIKit shell + SwiftUI screens)

`SceneDelegate` is the **composition root** — the only place where concrete dependencies are instantiated. It owns a `UINavigationController` and two local factory functions (`makeLoginVC`, `makeMainTabVC`) that create `UIHostingController` wrappers around SwiftUI views.

Screen transitions use `nav.setViewControllers(_:animated:)` (full replacement, not push/pop). Navigation callbacks are closure-injected at construction time — no Coordinator class needed at current scale.

```
SceneDelegate
├── makeLoginVC()  →  UIHostingController<LoginView>
└── makeMainTabVC() →  UIHostingController<MainTabView>
                           └── TabView with 5 NavigationStacks
```

### MVVM + Protocol-based DI

Every screen has a `ViewModel: ObservableObject` that owns all logic and state. Views are purely declarative. Dependencies are injected via initializer, always typed as protocols:

| Protocol | Concrete | Purpose |
|---|---|---|
| `SessionManagerProtocol` | `SessionManager` | Reads/writes session ID from `UserDefaults` |
| `TMDBAuthServiceProtocol` | `TMDBAuthService` | 3-step TMDB auth (completion-handler based) |
| `WatchlistServiceProtocol` | `WatchlistService` | Watchlist TMDB API (async/await) |

New services should use **async/await**. New ViewModels should be marked **`@MainActor`** (see `WatchlistViewModel` as the reference pattern). The older `LoginViewModel` uses completion handlers — do not copy that style.

### TMDB Authentication Flow

Three sequential API calls, all in `TMDBAuthService`, all completion-handler based:

1. `createRequestToken()` → temporary token
2. `validateLogin(username:password:requestToken:)` → validated token
3. `createSession(requestToken:)` → persistent `sessionId` stored via `SessionManager`

### Feature Structure

Each feature lives in its own folder:

```
Login/
  Model/          ← Decodable response types
  LoginView.swift
  LoginViewModel.swift
  TMDBAuthService.swift
Watchlist/
  Model/          ← WatchlistMovie, WatchlistTVShow, etc.
  WatchlistView.swift
  WatchlistViewModel.swift
  WatchlistService.swift
```

Movies, Series, and Search are currently placeholder views with no ViewModels.

### Localization

All user-visible strings go in `tmdb-app/Localizable.xcstrings`. Source language is English; Spanish Latin America (`es-419`) is the only active translation. Pass `LocalizedStringKey` (not `String`) through custom view parameters that end up in `Text()`, otherwise localization is bypassed.

## SwiftUI Previews Pattern

Use a configurable mock service to drive previews through the real `load()` path — do not bypass the ViewModel by setting `@Published` properties directly, because `.task` will overwrite them when the canvas renders. See `WatchlistView.swift` for the reference implementation (`MockWatchlistService` with `shouldHang`/`shouldFail` flags).
