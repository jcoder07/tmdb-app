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

The TMDB API key is **not** in source control. It lives in `TMDBSwiftUI/Config.xcconfig` (gitignored). Copy `Config.xcconfig.example` to `Config.xcconfig` and fill in the key. The xcconfig feeds `Info.plist`, which the app reads at runtime via `TMDBConfig.apiKey` (`TMDBCore/Core/TMDBConfig.swift`).

## Targets

| Target | Description |
|---|---|
| **TMDBSwiftUI** | Active app — pure SwiftUI, iOS 17+ |
| **TMDBCore** | Swift Package (swift-tools-version 6.3, `.swiftLanguageModes: [.v6]`) — all shared business logic |
| **TMDBUIKit** | Skeleton UIKit app, not actively developed |

## Architecture

### Composition Root (`TMDBSwiftUI/Composition/TMDBSwiftUIApp.swift`)

`TMDBSwiftUIApp: App` stores `SessionManager` and `HttpClient` as stored properties (app lifetime). It passes them to `AppRootView`, which owns `@State private var isLoggedIn: Bool` and drives all navigation:

```
TMDBSwiftUIApp
└── AppRootView (@State isLoggedIn)
    ├── isLoggedIn = false → NavigationStack { LoginView }
    └── isLoggedIn = true  → MainTabView (5 tabs)
                                ├── Home (NavigationStack)
                                ├── Movies (NavigationStack)
                                ├── Series (placeholder)
                                ├── Watchlist (NavigationStack)
                                └── Search (placeholder)
```

`AppRootView` creates all ViewModels via private `make*()` factory functions. When `isLoggedIn` flips to `false` (logout), the entire authenticated view tree is replaced and all authenticated ViewModels are released.

### MVVM + Protocol-based DI

Every feature screen has a ViewModel that owns all state and logic. Views are purely declarative. Dependencies are injected at initialisation time, typed as protocols:

| Protocol | Concrete | Purpose |
|---|---|---|
| `HttpClientProtocol` | `HttpClient` | Stateless async/await HTTP networking |
| `SessionManagerProtocol` | `SessionManager` | Reads/writes session ID via `UserDefaults` |
| `TMDBAuthServiceProtocol` | `TMDBAuthService` | 3-step TMDB auth flow |
| `MoviesServiceProtocol` | `MoviesService` | Popular movies + pagination |
| `MovieDetailServiceProtocol` | `MovieDetailService` | Movie detail, credits, reviews |
| `WatchlistServiceProtocol` | `WatchlistService` | Watchlist movies and TV shows |
| `ProfileServiceProtocol` | `ProfileService` | Facade over `AccountService` + `GenreService` |

All protocols conform to `Sendable`. All concrete service classes are implicitly `Sendable` (only store `let` properties of `Sendable` types — no `nonisolated(unsafe)` or `@unchecked Sendable` anywhere in the codebase).

### ViewModel Pattern

All TMDBCore ViewModels follow this pattern exactly (see `WatchlistViewModel` as the canonical reference):

```swift
@MainActor
@Observable
public final class SomeViewModel {
    private let service: any SomeServiceProtocol
    private let sessionManager: any SessionManagerProtocol
    // ...
}
```

- `@MainActor @Observable` — not `ObservableObject`/`@Published`
- Services stored as `any Protocol` — no `nonisolated(unsafe)` needed since protocols are `Sendable`
- `HomeViewModel` in TMDBSwiftUI is the only exception: it is a plain `final class` with no observable state (just a `logout()` method)

In views, `@Observable` ViewModels are used as:
- `var viewModel: SomeViewModel` — when the view only reads
- `@Bindable var viewModel: SomeViewModel` — when the view needs two-way bindings (e.g. `LoginView` binds `$viewModel.username`)

### Networking Layer

All HTTP calls go through `HttpClient` using a `Resource<T: Decodable>` to describe a request:

```swift
let resource = Resource(url: Constants.Urls.movieDetail(id: id), modelType: MovieDetailDTO.self)
let dto = try await httpClient.load(resource)
```

- `JSONDecoder.convertFromSnakeCase` — no `CodingKeys` needed for standard `snake_case` → `camelCase` conversions
- `JSONEncoder.convertToSnakeCase` — used automatically when creating a `Resource` with a body (POST requests)
- Only add `CodingKeys` when the Swift name doesn't match the converted key (e.g. `languageCode` for `iso_639_1`)
- All URLs live in `Constants.Urls` grouped by feature — never hardcode URLs in services

### DTO → Domain Model pattern

TMDBCore uses a two-layer model approach:

- **DTOs** (`internal`) — decode directly from JSON, live in `*/Model/*DTO.swift` files, never exposed outside TMDBCore
- **Domain models** (`public Sendable`) — clean Swift structs with explicit memberwise inits, live in `*/Model/*Models.swift` files
- Each domain model has an `internal init(_ dto:)` extension that handles the mapping

### TMDB Authentication Flow

Three sequential async calls in `TMDBAuthService`:

1. `createRequestToken()` → temporary token
2. `validateLogin(username:password:requestToken:)` → validated token  
3. `createSession(requestToken:)` → persistent `sessionId` stored via `SessionManager`

### Profile Feature Facade

`ProfileService` delegates to two focused services injected via `HttpClientProtocol`:

```
ProfileService (ProfileServiceProtocol facade)
├── AccountService  — /account, /account/{id}/rated/movies, /account/{id}/rated/tv
└── GenreService    — /genre/movie/list, /genre/tv/list
```

### Parallel Service Calls

Where independent requests can run concurrently, `async let` is used:

- `MovieDetailViewModel.load()` — detail, credits, and reviews fetched in parallel
- `WatchlistViewModel.load()` — account ID fetched first (required), then movies + TV shows in parallel
- `ProfileViewModel.load()` — account details fetched first, then rated movies, rated TV, movie genres, TV genres in parallel

### SwiftUI Color in TMDBCore

TMDBCore cannot import SwiftUI. `ProfileModels.GenreSlice` stores `colorHex: String` and `opacity: Double` instead of a `Color`. The view layer resolves these using the `Color(hex:)` extension in `TMDBSwiftUI/Support/Color+Hex.swift`:

```swift
Color(hex: slice.colorHex).opacity(slice.opacity)
```

### Localization

All user-visible strings go in `TMDBSwiftUI/Localizable.xcstrings`. Source language is English; Spanish Latin America (`es-419`) is fully translated. Pass `LocalizedStringKey` (not `String`) through custom view parameters that end up in `Text()`, otherwise localization is bypassed.

## SwiftUI Previews Pattern

Use a configurable mock service with `shouldHang: true` (loading state) and `shouldFail: true` (error state) to drive previews through the real ViewModel `load()` path. Do not set ViewModel properties directly — `.task` will overwrite them when the canvas renders. See `WatchlistView.swift` and `ProfileView.swift` for the reference implementations.
