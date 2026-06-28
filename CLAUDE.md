# CLAUDE.md

This file gives coding-agent guidance for the current `tmdb-app` repository. It was written from the actual codebase structure and should be kept in sync when targets, architecture, or build validation changes.

## Build & Validation

Use Xcode MCP tools for this project. Prefer these over direct `xcodebuild` calls:

- `XcodeRefreshCodeIssuesInFile`: fast diagnostics for every Swift file you edit.
- `BuildProject`: full project build; use before declaring broad changes complete.
- `RunAllTests`: run the whole test suite when available.
- `RunSomeTests`: run focused tests while iterating.

The current `TMDBCoreTests.swift` only contains the default Swift Testing placeholder. Add real tests under `TMDBCore/Tests/TMDBCoreTests/` when changing core logic or ViewModel behavior.

## Configuration & Secrets

The TMDB API key is read from `Bundle.main.infoDictionary["TMDB_API_KEY"]` in `TMDBCore/Core/TMDBConfig.swift`. `TMDBSwiftUI/Config.xcconfig.example` shows the expected setup:

```xcconfig
TMDB_API_KEY = your_api_key_here
INFOPLIST_KEY_TMDB_API_KEY = $(TMDB_API_KEY)
```

Do not commit real API keys. Keep local `Config.xcconfig` files environment-specific.

## Targets & Module Layout

- `TMDBCore`: Swift Package, iOS 17+, Swift 6 mode, no third-party dependencies. Owns networking, session storage, services, DTOs, domain models, and ViewModels.
- `TMDBSwiftUI`: SwiftUI app target and current primary UI. Feature folders: `Home`, `Login`, `Movies`, `Detail`, `Profile`, `Watchlist`, `Search`, `Series`.
- `TMDBUIKit`: UIKit app target using the same `TMDBCore` ViewModels and services. It has a UIKit composition root, tab bar, and feature controllers.

Keep business logic in `TMDBCore`. UI targets should compose dependencies, render state, and handle platform-specific navigation.

## Composition Roots

`TMDBSwiftUI/Composition/TMDBSwiftUIApp.swift` is the SwiftUI composition root. `TMDBSwiftUIApp` creates app-lifetime `SessionManager` and `HttpClient`, then passes them into `AppRootView`.

`AppRootView` owns `@State private var isLoggedIn` initialized from `sessionManager.isLoggedIn`. It switches between:

```text
logged out -> NavigationStack { LoginView }
logged in  -> MainTabView with Home, Movies, Series, Watchlist, Search
```

Factory methods create `LoginViewModel`, `HomeViewModel`, `MoviesViewModel`, `WatchlistViewModel`, and `ProfileViewModel`. Logout clears the session in the relevant ViewModel and flips `isLoggedIn` through the injected closure.

`TMDBUIKit/Composition/SceneDelegate.swift` mirrors this setup with `SessionManager` and `HttpClient` stored for app lifetime. It installs either a login navigation controller or a tab bar and transitions root controllers with a cross-dissolve.

## Core Architecture

ViewModels in `TMDBCore` use Observation:

```swift
@MainActor
@Observable
public final class SomeViewModel { }
```

Dependencies are injected as protocols and stored as existentials, for example:

```swift
private let service: any MoviesServiceProtocol
private let sessionManager: any SessionManagerProtocol
```

Protocols such as `HttpClientProtocol`, service protocols, and `SessionManagerProtocol` conform to `Sendable`. Concrete services are `final class` types with immutable `httpClient` or facade dependencies.

Use `async`/`await`; do not introduce Combine for new app logic.

## Networking Rules

All network calls go through `HttpClient.load(_:)` with `Resource<T: Decodable>`.

- `Resource(url:modelType:)` is used for GET-style requests.
- `Resource(url:body:modelType:)` encodes request bodies using `.convertToSnakeCase` and creates POST requests.
- `HttpClient` decodes responses using `.convertFromSnakeCase`.
- URLs belong in `Constants.Urls`; do not hardcode TMDB API URLs inside services.
- Image URLs are built by `Constants.Urls.poster`, `backdrop`, and `gravatar`.

`NetworkError` maps invalid requests, invalid responses, server messages, and decoding failures into localized descriptions.

## Models & DTO Mapping

DTOs are internal `Decodable` structs in `*/Model/*DTO.swift`. Domain models are public `Sendable` structs in `*/Model/*Models.swift`, often also `Identifiable` for UI lists.

Mapping is done with internal DTO initializers, for example:

```swift
extension Movie {
    init(_ dto: PopularMovieDTO) { ... }
}
```

Keep this two-layer pattern when adding endpoints. Only add `CodingKeys` when Swift names cannot be handled by the decoder's snake-case conversion.

## Feature Flow Notes

- Login performs the TMDB three-step auth flow: create request token, validate login, create session, then save `sessionId` with `SessionManager`.
- Movies loads popular movies with pagination and caches `MovieDetailViewModel` instances by movie ID.
- Movie detail fetches detail, credits, and reviews concurrently with `async let`.
- Watchlist fetches account ID first, then movies and TV shows concurrently.
- Profile fetches account details first, then rated movies, rated TV, movie genres, and TV genres concurrently; it computes score summaries, rating distribution, and genre slices.

## SwiftUI Conventions

SwiftUI views receive `@Observable` ViewModels as plain stored properties when they only read state. Use `@Bindable` only when the view writes through bindings, such as `WatchlistContentView` binding the selected tab.

Use `.task { await viewModel.load() }` for screen loading. Provide loading, error, empty, and content states where data is remote.

Localized SwiftUI text lives in `TMDBSwiftUI/Localizable.xcstrings` with English as source language and `es-419` entries. When a custom view parameter will be rendered by `Text`, prefer `LocalizedStringKey` over `String`.

`TMDBCore` must not import SwiftUI. Profile colors are represented as hex strings in core models and resolved in `TMDBSwiftUI/Support/Color+Hex.swift`.

## UIKit Conventions

UIKit controllers use the same `@Observable` ViewModels via `withObservationTracking` loops that call `render()` and resubscribe on change. Keep controller code focused on layout, actions, and rendering. Use descriptive local names for UIKit factories (`imageView`, `label`, `button`, `segmentedControl`).

Async images in UIKit use `TMDBUIKit/Support/UIImageView+AsyncLoad.swift`; SwiftUI uses `AsyncImage`.

## Preview Pattern

SwiftUI previews should use protocol-backed mock services and real ViewModels. Prefer exercising the same `.task { await viewModel.load() }` path used at runtime. For loading and error previews, mock services can hang with `Task.sleep(nanoseconds: .max)` or throw an error, as in `WatchlistView.swift`.

## Change Discipline

Keep edits scoped to the requested target and feature. Do not move logic between `TMDBCore`, `TMDBSwiftUI`, and `TMDBUIKit` unless the task requires it. When changing shared protocols or domain models, update both app targets as needed and validate with `BuildProject`.
