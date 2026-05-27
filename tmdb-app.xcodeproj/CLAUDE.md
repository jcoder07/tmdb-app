# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

Use the Xcode MCP tools for all build and test operations:

- **Build**: `BuildProject`
- **Run all tests**: `RunAllTests`
- **Run specific tests**: `RunSomeTests`
- **Check code issues**: `XcodeRefreshCodeIssuesInFile` (fast, use before full build)

## Architecture

UIKit-based iOS app with programmatic UI (no Storyboards for screens). All layout uses `NSLayoutConstraint` / `UIStackView`.

### Authentication Flow

The app implements the 3-step TMDB authentication protocol:

1. `TMDBAuthService.createRequestToken()` → gets a temporary token from TMDB
2. `TMDBAuthService.validateLogin(username:password:requestToken:)` → exchanges credentials for a validated token
3. `TMDBAuthService.createSession(requestToken:)` → converts the validated token into a persistent session ID

All three steps use completion-handler-based `URLSession.dataTask` calls (not async/await).

### Session Persistence

`SessionManager` (singleton) stores the TMDB session ID in `UserDefaults` under the key `tmdb_session_id`. It is the source of truth for auth state.

### Navigation

`SceneDelegate` checks `SessionManager.shared.isLoggedIn` at launch to decide the root view controller — `LoginViewController` or `HomeViewController` — wrapped in a `UINavigationController`. Screen transitions use `navigationController?.setViewControllers(_:animated:)` (not push/pop).

### Response Models

- `RequestTokenResponse` — used for both Step 1 and Step 2 responses (both return a token)
- `CreateSessionResponse` — used for Step 3, contains `sessionId`

## Known Issues / Notes

- The TMDB API key is hardcoded in `TMDBAuthService`. Move it to a config file or environment variable before shipping.
- `ITunesSearchResponse` and `Song` structs are currently defined inside `LoginControllerView.swift` — they belong in their own file.
- UI strings are in Spanish (placeholders, button titles).
- The login flow uses deeply nested completion handlers; consider refactoring to async/await.
