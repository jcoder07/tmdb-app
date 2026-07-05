# Agent Instructions

You are a senior software engineer specialized in Swift, iOS, SwiftUI, UIKit, Vapor, PostgreSQL, JavaScript, TypeScript, Lit, and web components.

When reviewing code:
- Prioritize correctness, maintainability, performance, and memory safety.
- Check iOS 17 compatibility.
- Look for retain cycles, threading issues, Combine/SwiftUI state bugs, and architectural coupling.
- Give practical code examples.
- Avoid rewriting everything unless necessary.
- Explain tradeoffs clearly.

# Repository Guidelines

## Project Overview

TMDB iOS app with two UI targets (SwiftUI, UIKit) sharing a local Swift Package for business logic. The app lets users browse popular movies, view details, manage a watchlist, and see their profile/ratings via The Movie Database (TMDB) API.

- Minimum iOS: **17.6** (app targets), **17.0** (TMDBCore package minimum)
- Swift Language Mode: **6** (TMDBCore), **5.0** (app targets with `SWIFT_APPROACHABLE_CONCURRENCY = YES` and `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- Dependencies: **SPM only** (local TMDBCore package). No CocoaPods, no Carthage, no third-party dependencies.

## Targets & Module Layout

```
tmdb-app/
├── TMDBCore/                     # Swift Package — shared business logic
│   ├── Package.swift              # swift-tools-version: 6.3, platforms: .iOS(.v17)
│   ├── Sources/TMDBCore/
│   │   ├── Core/                  # HttpClient, SessionManager, Constants, TMDBConfig
│   │   ├── Login/                 # Auth flow: request token → validate → create session
│   │   ├── Movies/                # Popular movies list with pagination
│   │   ├── Detail/                # Movie detail, credits, reviews
│   │   ├── Profile/               # Account details, rated content, genres, computed stats
│   │   ├── Watchlist/             # Tabbed watchlist (movies/TV) with pagination
│   │   ├── Search/                # (empty — placeholder)
│   │   └── Series/                # (empty — placeholder)
│   └── Tests/TMDBCoreTests/       # Swift Testing tests
├── TMDBSwiftUI/                   # Primary SwiftUI app target
│   ├── Composition/               # App entry, AppRootView, factory methods
│   ├── Home/ Login/ Movies/ Detail/ Profile/ Watchlist/ Search/ Series/
│   ├── Support/                   # Color+Hex, utilities
│   ├── Localizable.xcstrings      # English + es-419
│   └── Config.xcconfig / Config.xcconfig.example
├── TMDBUIKit/                     # UIKit app target (same TMDBCore)
│   ├── Composition/               # SceneDelegate, AppDelegate
│   ├── Home/ Login/ Movies/ Detail/ Profile/ Watchlist/ Search/ Series/
│   ├── Support/                   # UIImageView+AsyncLoad
│   └── Config.xcconfig / Config.xcconfig.example
├── Test-HTTPClient/               # Standalone test harness for HttpClient (iOS 27.0)
├── tmdb-app/                      # Legacy directory — NOT referenced by the project
└── tmdb-app.xcodeproj/            # Xcode project (no workspace)
```

## Key Technologies

- **SwiftUI** with `@Observable` (iOS 17+ Observation framework)
- **UIKit** with `withObservationTracking` loops for reactive rendering
- **async/await** for all async work — no Combine used in new code
- **Swift Testing** (`import Testing` with `#expect`) for unit tests
- **Swift 6** strict concurrency (Sendable, MainActor, global actors)
- **No third-party dependencies** — only Foundation, SwiftUI, UIKit, Observation

## Architecture Rules

### Layer Separation
- `TMDBCore` owns networking, session storage, DTOs, domain models, service protocols, and ViewModels.
- `TMDBSwiftUI` / `TMDBUIKit` own rendering, navigation, platform-specific UI, and dependency composition.
- `TMDBCore` must **never import SwiftUI** or UIKit.

### Dependency Injection
- ViewModels receive protocol existentials via init:
  ```swift
  private let service: any MoviesServiceProtocol
  private let sessionManager: any SessionManagerProtocol
  ```
- Composition roots (`TMDBSwiftUIApp.swift`, `SceneDelegate.swift`) create concrete services and inject them into ViewModels.

### ViewModel Pattern
```swift
@MainActor
@Observable
public final class SomeViewModel {
    public private(set) var state = ...
    private let service: any SomeServiceProtocol
    // ...
}
```

### Networking
- All requests go through `HttpClient.load(_:)` with `Resource<T: Decodable>`.
- URLs are centralized in `Constants.Urls` — never hardcoded in services.
- DTOs are `internal` `Decodable` structs. Domain models are `public` `Sendable` `Identifiable` structs.

## Build & Test Commands

Since Xcode MCP tools may not always be available, use `xcodebuild`:

```bash
# Build TMDBCore package
xcodebuild -project tmdb-app.xcodeproj -scheme TMDBCore -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build

# Build TMDBSwiftUI app
xcodebuild -project tmdb-app.xcodeproj -scheme TMDBSwiftUI -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build

# Build for testing (compiles tests without running them)
xcodebuild -project tmdb-app.xcodeproj -scheme TMDBCore -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' build-for-testing

# Run tests (requires a booted simulator)
xcodebuild -project tmdb-app.xcodeproj -scheme TMDBCore -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

**Note:** The `TMDBCore` scheme may not have the test action configured in Xcode. If `test` fails with "not configured for the test action", use `build-for-testing` to verify compilation, or run tests from Xcode directly.

## Testing Guidelines

- Tests go in `TMDBCore/Tests/TMDBCoreTests/` using Swift Testing framework.
- Name tests by expected behavior: `loadSetsErrorMessageWhenServiceFails`.
- Mock services conform to the protocol and simulate success/failure/hanging.
- Use `@MainActor` on ViewModel tests since all ViewModels are `@MainActor`.
- Cover: service mapping, ViewModel state transitions (loading, loaded, error, empty), re-entry guards, pagination.

## Coding Style

- 4-space indentation, Swift 6 conventions.
- PascalCase for types, camelCase for properties/methods/locals.
- Descriptive names: `viewModel`, `sessionManager`, `httpClient` — no abbreviations.
- No comments unless explaining a non-obvious design decision.
- Use `defer` for cleanup (isLoading, etc.) to guarantee execution on all exit paths.

## Memory Safety Rules

1. **Retain cycles in closures:** Use `[weak self]` in escaping closures that reference `self`. Use `[weak viewModel]` in observation callbacks.
2. **Delegates:** Always declare delegate properties as `weak var` to avoid strong reference cycles.
3. **Combine subscriptions:** Store `AnyCancellable` in a `Set<AnyCancellable>` and use `weak self` in sink closures. (Note: new code should prefer async/await over Combine.)
4. **Observation:** `@Observable` classes manage observation automatically. Do not hold strong references to observation registrars.
5. **Task lifecycle:** `.refreshable` and `.task` can be cancelled by SwiftUI. Use `Task.isCancelled` checks and `defer` blocks to ensure proper cleanup.

## iOS Compatibility Rules

1. Use iOS 17 APIs only. Do not use APIs from iOS 18+ without availability checks.
2. `@Observable` macro requires iOS 17.
3. `AsyncImage` requires iOS 15 (available, but iOS 17 is the floor).
4. `SwiftUI.AsyncImage` phase-based loading is preferred over custom image loaders.
5. NavigationStack requires iOS 16 (available).
6. Do not use `@available(iOS 18, *)` APIs.
7. The `Test-HTTPClient` target targets iOS 27.0 — it's an internal experiment harness, not for production.

## What Not to Change Without Asking

- **Do not** modify `TMDBConfig.swift` or the Info.plist API key resolution mechanism.
- **Do not** move code between `TMDBCore`, `TMDBSwiftUI`, and `TMDBUIKit` — each has a defined role.
- **Do not** add third-party dependencies without explicit approval.
- **Do not** commit real API keys. `Config.xcconfig` files with real keys must be gitignored.
- **Do not** delete the `tmdb-app/` legacy directory — its purpose is not confirmed.
- **Do not** modify the `Test-HTTPClient` target — it's a personal experiment harness.
- **Do not** change the `Package.swift` platforms or tools version without team consensus.
- **Do not** modify `xcshareddata/xcschemes/` scheme files — Xcode auto-manages these.

## Commit & Pull Request Guidelines

Short imperative messages matching repo style:
- `Add pagination to WatchlistViewModel`
- `Fix pull-to-refresh cancellation handling`
- `Extract WatchlistView previews to separate file`

PRs should include: summary of changes, validation performed, screenshots for UI changes, and any API key / config assumptions.

## Security

- TMDB API key is in `Bundle.main.infoDictionary["TMDB_API_KEY"]`, resolved from `Config.xcconfig`.
- Never commit `Config.xcconfig` files containing real secrets.
- URLs must stay centralized in `Constants.Urls` — no URL construction in services.
