import Foundation

/// Raw JSON fixtures shaped to match the real TMDB DTOs, so tests exercise genuine decoding
/// rather than a placeholder payload. Keep required (non-optional) DTO fields present.
enum Fixtures {

    // MARK: - Auth

    static let requestToken = """
    {"success": true, "expires_at": "2026-01-01 00:00:00 UTC", "request_token": "fixture-request-token"}
    """

    static let requestTokenMissing = """
    {"success": true, "expires_at": "2026-01-01 00:00:00 UTC", "request_token": null}
    """

    static let validateLoginOK = """
    {"success": true, "expires_at": "2026-01-01 00:00:00 UTC", "request_token": "fixture-request-token"}
    """

    static let createSession = """
    {"success": true, "session_id": "fixture-session-id"}
    """

    static let tmdbAuthError = """
    {"success": false, "status_code": 30, "status_message": "Invalid username and/or password."}
    """

    // MARK: - Movies

    static func popularMovies(page: Int, totalPages: Int, ids: [Int]) -> String {
        let results = ids.map {
            """
            {"id": \($0), "title": "Movie \($0)", "poster_path": "/poster\($0).jpg", "backdrop_path": null, "vote_average": 7.5, "release_date": "2024-01-01"}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    static let malformedMovies = """
    {"oops": "not a valid popular-movies payload"}
    """

    // MARK: - Watchlist

    static func watchlistMovies(page: Int, totalPages: Int, ids: [Int]) -> String {
        let results = ids.map {
            """
            {"id": \($0), "title": "Watchlist Movie \($0)", "overview": "Overview \($0)", "poster_path": null, "vote_average": 6.5, "release_date": "2023-05-01"}
            """
        }.joined(separator: ",")
        return """
        {"page": \(page), "results": [\(results)], "total_pages": \(totalPages)}
        """
    }

    static func watchlistTVShows(page: Int, totalPages: Int, ids: [Int]) -> String {
        let results = ids.map {
            """
            {"id": \($0), "name": "Watchlist Show \($0)", "overview": "Overview \($0)", "poster_path": null, "vote_average": 8.0, "first_air_date": "2022-09-01"}
            """
        }.joined(separator: ",")
        return """
        {"page": \(page), "results": [\(results)], "total_pages": \(totalPages)}
        """
    }

    static let tmdbStatusOK = """
    {"success": true, "status_code": 1, "status_message": "Success."}
    """

    static let tmdbStatusError = """
    {"success": false, "status_code": 34, "status_message": "The resource you requested could not be found."}
    """

    // MARK: - Account

    static func accountProfile(id: Int = 555, username: String = "fixture-user") -> String {
        """
        {
          "id": \(id),
          "username": "\(username)",
          "name": "Fixture User",
          "avatar": {
            "gravatar": {"hash": "abc123"},
            "tmdb": {"avatar_path": null}
          },
          "iso_639_1": "en",
          "iso_3166_1": "US",
          "include_adult": false
        }
        """
    }

    // MARK: - Home / Trending / Discover

    static func multiSearch(page: Int = 1, totalPages: Int = 1, movieIds: [Int] = [], personIds: [Int] = []) -> String {
        let movies = movieIds.map {
            """
            {"id": \($0), "media_type": "movie", "title": "Trending Movie \($0)", "release_date": "2024-02-01", "name": null, "first_air_date": null, "profile_path": null, "known_for": null, "poster_path": null, "vote_average": 7.0}
            """
        }
        let people = personIds.map {
            """
            {"id": \($0), "media_type": "person", "title": null, "release_date": null, "name": "Person \($0)", "first_air_date": null, "profile_path": null, "known_for": [], "poster_path": null, "vote_average": null}
            """
        }
        let results = (movies + people).joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    static func onTheAirSeries(ids: [Int]) -> String {
        let results = ids.map {
            """
            {"id": \($0), "name": "Series \($0)", "poster_path": null, "backdrop_path": null, "vote_average": 7.2, "first_air_date": "2021-03-01"}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)], "page": 1, "total_pages": 1}
        """
    }

    static func videos(keys: [(key: String, site: String, type: String)]) -> String {
        let results = keys.map {
            """
            {"id": "\($0.key)", "key": "\($0.key)", "site": "\($0.site)", "type": "\($0.type)", "official": true}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)]}
        """
    }
}
