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

The TMDB API key is **not** in source control. It lives in `tmdb-app/Config.xcconfig` (gitignored). Copy `Config.xcconfig.example` to `Config.xcconfig` and fill in the key. The xcconfig feeds `Info.plist`, which the app reads at runtime via `TMDBConfig.apiKey` (`Core/TMDBConfig.swift`).

## Architecture

### Navigation (UIKit shell + SwiftUI screens)

`SceneDelegate` is the **composition root** — the only place where concrete dependencies are instantiated. It owns a `UINavigationController` and two local factory functions (`makeLoginVC`, `makeMainTabVC`) that create `UIHostingController` wrappers around SwiftUI views.

Screen transitions use `nav.setViewControllers(_:animated:)` (full replacement, not push/pop). Navigation callbacks are closure-injected at construction time — no Coordinator class needed at current scale.

```
SceneDelegate
├── makeLoginVC()   → UIHostingController<LoginView>
└── makeMainTabVC() → UIHostingController<MainTabView>
                          └── TabView with 5 NavigationStacks
                              (Home, Movies, Series, Watchlist, Search)
```

### MVVM + Protocol-based DI

Every screen has a `ViewModel: ObservableObject` that owns all logic and state. Views are purely declarative. Dependencies are injected via initializer, always typed as protocols:

| Protocol | Concrete | Purpose |
|---|---|---|
| `SessionManagerProtocol` | `SessionManager` | Reads/writes session ID from `UserDefaults` |
| `TMDBAuthServiceProtocol` | `TMDBAuthService` | 3-step TMDB auth (completion-handler based) |
| `HttpClientProtocol` | `HttpClient` | Generic async/await HTTP networking |
| `WatchlistServiceProtocol` | `WatchlistService` | Watchlist TMDB API |
| `ProfileServiceProtocol` | `ProfileService` | Facade over `AccountService` + `GenreService` |

New services should use **async/await** via `HttpClient`. New ViewModels should be marked **`@MainActor`** (see `WatchlistViewModel` as the reference pattern). The older `LoginViewModel` uses completion handlers — do not copy that style.

### Networking Layer (`Core/`)

All HTTP calls go through `HttpClient`, which uses a `Resource<T: Decodable>` struct to describe a request and decodes responses automatically:

```swift
let resource = Resource(url: Constants.Urls.account(sessionId: id), modelType: AccountProfile.self)
let profile = try await httpClient.load(resource)
```

`HttpClient.load` uses `JSONDecoder` with `.convertFromSnakeCase`, so models do **not** need `CodingKeys` for standard snake_case conversions (e.g. `poster_path` → `posterPath`). Only add `CodingKeys` when the Swift property name doesn't match the snake_case-converted JSON key (e.g. `AccountProfile` uses `languageCode` for `iso_639_1`).

All URLs live in `Constants.Urls` (`Core/Constants.swift`), grouped by feature (Auth, Account, Watchlist, Genres, Images). Never hardcode URLs in services.

### TMDB Authentication Flow

Three sequential API calls in `TMDBAuthService`, completion-handler based (legacy — do not copy):

1. `createRequestToken()` → temporary token
2. `validateLogin(username:password:requestToken:)` → validated token
3. `createSession(requestToken:)` → persistent `sessionId` stored via `SessionManager`

### Profile Feature Structure

`ProfileService` is a **facade** — it implements `ProfileServiceProtocol` by delegating to two focused services, both injected via `HttpClientProtocol`:

```
ProfileService (facade)
├── AccountService  — /account, /account/{id}/rated/movies, /account/{id}/rated/tv
└── GenreService    — /genre/movie/list, /genre/tv/list
```

The split means `ProfileViewModel` depends only on `ProfileServiceProtocol` and is unaware of the internal decomposition.

### Feature Structure

```
Core/               ← Shared infrastructure (HttpClient, Constants, TMDBConfig, SessionManager)
Login/
  Model/            ← RequestTokenResponse, CreateSessionResponse
  LoginView / LoginViewModel / TMDBAuthService
Home/               ← HomeView, HomeViewModel, MainTabView
Profile/
  Model/            ← AccountProfile, RatedMovie, RatedTVShow, GenreItem, etc.
  ProfileView / ProfileViewModel
  ProfileService (facade) / AccountService / GenreService
Watchlist/
  Model/            ← WatchlistMovie, WatchlistTVShow, WatchlistResponse
  WatchlistView / WatchlistViewModel / WatchlistService
```

Movies, Series, and Search are currently placeholder views with no ViewModels.

### Localization

All user-visible strings go in `tmdb-app/Localizable.xcstrings`. Source language is English; Spanish Latin America (`es-419`) is the only active translation. Pass `LocalizedStringKey` (not `String`) through custom view parameters that end up in `Text()`, otherwise localization is bypassed.

## SwiftUI Previews Pattern

Use a configurable mock service to drive previews through the real `load()` path — do not bypass the ViewModel by setting `@Published` properties directly, because `.task` will overwrite them when the canvas renders. Use `shouldHang: true` for loading state and `shouldFail: true` for error state. See `WatchlistView.swift` and `ProfileView.swift` for the reference implementations.
