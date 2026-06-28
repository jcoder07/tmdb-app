# Repository Guidelines

## Project Structure & Module Organization

This repository contains two iOS app targets plus a shared Swift package:

- `TMDBCore/`: Swift Package with shared business logic, services, DTOs, domain models, and tests.
- `TMDBSwiftUI/`: Active SwiftUI app target. Feature folders include `Login`, `Movies`, `Detail`, `Profile`, `Watchlist`, and `Home`.
- `TMDBUIKit/`: UIKit app skeleton using the same `TMDBCore` package.
- `TMDBCore/Tests/TMDBCoreTests/`: unit tests for shared logic.
- `TMDBSwiftUI/Assets.xcassets` and `TMDBUIKit/Assets.xcassets`: app assets.

Keep networking, model mapping, session handling, and feature ViewModels in `TMDBCore`. Keep rendering and platform-specific UI in the app targets.

## Build, Test, and Development Commands

Use the Xcode MCP tools for validation instead of calling `xcodebuild` directly:

- `BuildProject`: builds the selected Xcode project and verifies compilation.
- `XcodeRefreshCodeIssuesInFile`: fast diagnostics for files you edit.
- `RunAllTests`: runs the project test suite.
- `RunSomeTests`: runs selected tests when iterating on focused changes.

For API setup, copy `TMDBSwiftUI/Config.xcconfig.example` to `TMDBSwiftUI/Config.xcconfig` and add the TMDB API key. Do not commit real keys.

## Coding Style & Naming Conventions

Use Swift 6 style with 4-space indentation. Prefer descriptive names (`viewModel`, `imageView`, `sessionManager`) over abbreviations. Types use `PascalCase`; properties, methods, and locals use `camelCase`.

TMDBCore ViewModels should be `@MainActor @Observable final class` types. Prefer `async`/`await` over Combine. Store dependencies as protocol existentials, for example:

```swift
private let service: any MoviesServiceProtocol
```

DTOs are internal and map into public `Sendable` domain models.

## Testing Guidelines

Add tests under `TMDBCore/Tests/TMDBCoreTests/` for shared logic, service behavior, and ViewModel state transitions. Name tests after expected behavior, such as `loadSetsErrorMessageWhenServiceFails`.

Run `XcodeRefreshCodeIssuesInFile` on edited Swift files, then `BuildProject`. Use `RunAllTests` when changing TMDBCore contracts or ViewModel behavior.

## Commit & Pull Request Guidelines

Recent commits use short imperative messages, for example `Rename short UIKit variables` and `Adopt Sendable throughout TMDBCore`. Keep commits focused on one logical change.

Pull requests should include a concise summary, validation performed, linked issue if applicable, and screenshots for visible UI changes. Note any API-key or configuration assumptions.

## Security & Configuration Tips

Never commit `Config.xcconfig` with real secrets. Keep all TMDB endpoints centralized in `Constants.Urls`; do not hardcode URLs in feature services.
