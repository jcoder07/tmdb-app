//
//  UITestFixtures.swift
//  TMDBSwiftUI
//

#if DEBUG

import Foundation

/// Raw JSON fixtures shaped to the real TMDB DTOs so the app exercises genuine decoding under
/// UI test, and the catalog of items those fixtures contain.
///
/// Every non-optional DTO field must be present or decoding throws and the screen shows an error
/// state instead of content. The shapes here mirror
/// `TMDBSwiftUIIntegrationTests/Support/Fixtures.swift`, which already encodes those requirements.
///
/// The `movieTitles` / `seriesTitles` / `personNames` tables are the single source of truth for
/// what the UI renders: list fixtures are built from them, and the `/movie/{id}`-style detail
/// routes look up the same tables, so a detail screen always shows the title of the card tapped.
/// `TMDBSwiftUIUITests/Support/UITestCatalog.swift` repeats these literals for assertions.
enum UITestFixtures {

    // MARK: - Catalog

    static let moviesPageOne = [1101, 1102, 1103, 1104]
    static let moviesPageTwo = [1105, 1106]
    static let streamingMovies = [1201, 1202]
    static let freeMovies = [1301, 1302]
    static let rentMovies = [1401]
    static let nowPlayingMovies = [1501]
    static let genreMovies = [1601, 1602]
    static let searchMovies = [1701]

    static let popularSeries = [2201, 2202, 2203]
    static let onTheAirSeries = [2301]
    static let freeSeries = [2401]
    static let genreSeries = [2501]
    static let searchSeries = [2601]

    static let searchPeople = [3401]
    static let popularPeople = [3501]

    static let movieTitles: [Int: String] = [
        1101: "Arrival Protocol",
        1102: "Neon Harbor",
        1103: "The Quiet Ledger",
        1104: "Ashfall",
        1105: "Glass Meridian",
        1106: "Salt and Static",
        1201: "Streaming Standout",
        1202: "Midnight Rerun",
        1301: "Free Reel",
        1302: "Public Domain Heist",
        1401: "Rental Row",
        1501: "Opening Weekend",
        1601: "Genre Pick Alpha",
        1602: "Genre Pick Beta",
        1701: "Searched Feature"
    ]

    static let seriesTitles: [Int: String] = [
        2201: "Harbor Lights",
        2202: "The Long Winter",
        2203: "Cinder Court",
        2301: "Night Shift Ward",
        2401: "Free Airwaves",
        2501: "Genre Series Alpha",
        2601: "Searched Series"
    ]

    static let personNames: [Int: String] = [
        3401: "Ada Fixture",
        3501: "Rex Placeholder"
    ]

    static let searchQueryWithResults = "harbor"
    static let searchQueryWithoutResults = "zzzznotfound"

    static func movieTitle(_ id: Int) -> String { movieTitles[id] ?? "Movie \(id)" }
    static func seriesTitle(_ id: Int) -> String { seriesTitles[id] ?? "Series \(id)" }
    static func personName(_ id: Int) -> String { personNames[id] ?? "Person \(id)" }

    // MARK: - Movie lists (PopularMoviesResponseDTO)

    static func movieList(ids: [Int], page: Int = 1, totalPages: Int = 1) -> String {
        let results = ids.map { id in
            """
            {"id": \(id), "title": "\(movieTitle(id))", "poster_path": null, "backdrop_path": null, \
            "vote_average": 7.5, "release_date": "2024-01-01"}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    // MARK: - Series lists (PopularSeriesResponseDTO)

    static func seriesList(ids: [Int], page: Int = 1, totalPages: Int = 1) -> String {
        let results = ids.map { id in
            """
            {"id": \(id), "name": "\(seriesTitle(id))", "poster_path": null, "backdrop_path": null, \
            "vote_average": 8.0, "first_air_date": "2022-09-01"}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    // MARK: - Multi search / trending (MultiSearchResponseDTO)

    static func multi(
        movieIds: [Int] = [],
        seriesIds: [Int] = [],
        personIds: [Int] = [],
        page: Int = 1,
        totalPages: Int = 1
    ) -> String {
        let movies = movieIds.map { id in
            """
            {"id": \(id), "media_type": "movie", "title": "\(movieTitle(id))", \
            "release_date": "2024-02-01", "name": null, "first_air_date": null, \
            "profile_path": null, "known_for": null, "poster_path": null, "vote_average": 7.0}
            """
        }
        let series = seriesIds.map { id in
            """
            {"id": \(id), "media_type": "tv", "title": null, "release_date": null, \
            "name": "\(seriesTitle(id))", "first_air_date": "2021-04-01", \
            "profile_path": null, "known_for": null, "poster_path": null, "vote_average": 8.1}
            """
        }
        let people = personIds.map { id in
            """
            {"id": \(id), "media_type": "person", "title": null, "release_date": null, \
            "name": "\(personName(id))", "first_air_date": null, "profile_path": null, \
            "known_for": [], "poster_path": null, "vote_average": null}
            """
        }
        let results = (movies + series + people).joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    // MARK: - Popular people (PopularPeopleResponseDTO)

    static func peopleList(ids: [Int], page: Int = 1, totalPages: Int = 1) -> String {
        let results = ids.map { id in
            """
            {"id": \(id), "name": "\(personName(id))", "profile_path": null, "known_for": []}
            """
        }.joined(separator: ",")
        return """
        {"results": [\(results)], "page": \(page), "total_pages": \(totalPages)}
        """
    }

    // MARK: - Detail payloads

    static func movieDetail(id: Int) -> String {
        """
        {
          "id": \(id),
          "title": "\(movieTitle(id))",
          "overview": "A fixture overview used by the UI test harness.",
          "backdrop_path": null,
          "poster_path": null,
          "release_date": "2024-01-01",
          "vote_average": 7.5,
          "vote_count": 1234,
          "runtime": 118,
          "genres": [{"id": 28, "name": "Action"}],
          "tagline": "Fixtures all the way down.",
          "status": "Released",
          "budget": 1000000,
          "revenue": 5000000
        }
        """
    }

    static func seriesDetail(id: Int) -> String {
        """
        {
          "id": \(id),
          "name": "\(seriesTitle(id))",
          "overview": "A fixture overview used by the UI test harness.",
          "backdrop_path": null,
          "poster_path": null,
          "first_air_date": "2022-09-01",
          "vote_average": 8.0,
          "vote_count": 4321,
          "number_of_seasons": 3,
          "number_of_episodes": 24,
          "genres": [{"id": 18, "name": "Drama"}],
          "tagline": "Fixtures all the way down.",
          "status": "Returning Series"
        }
        """
    }

    static func personDetail(id: Int) -> String {
        """
        {
          "id": \(id),
          "name": "\(personName(id))",
          "biography": "A fixture biography used by the UI test harness.",
          "profile_path": null,
          "birthday": "1980-05-05",
          "place_of_birth": "Cupertino, California",
          "known_for_department": "Acting"
        }
        """
    }

    // MARK: - Credits / reviews / videos / genres

    static let credits = """
    {"cast": [
      {"id": 9001, "name": "Cast One", "character": "Lead", "profile_path": null, "order": 0},
      {"id": 9002, "name": "Cast Two", "character": "Support", "profile_path": null, "order": 1}
    ]}
    """

    static let combinedCredits = """
    {"cast": [
      {"id": 1101, "media_type": "movie", "title": "Arrival Protocol", "release_date": "2024-01-01", \
    "name": null, "first_air_date": null, "poster_path": null, "vote_average": 7.5},
      {"id": 2201, "media_type": "tv", "title": null, "release_date": null, \
    "name": "Harbor Lights", "first_air_date": "2022-09-01", "poster_path": null, "vote_average": 8.0}
    ]}
    """

    static let reviews = """
    {"results": [
      {"id": "review-1", "author": "Fixture Critic", "content": "Consistently reproducible.", \
    "created_at": "2024-03-01T00:00:00.000Z", "author_details": {"rating": 8.0, "avatar_path": null}}
    ], "total_results": 1}
    """

    static let videos = """
    {"results": [
      {"id": "video-1", "key": "fixtureKey", "site": "YouTube", "type": "Trailer", "official": true}
    ]}
    """

    static let movieGenres = """
    {"genres": [
      {"id": 28, "name": "Action"},
      {"id": 35, "name": "Comedy"},
      {"id": 18, "name": "Drama"}
    ]}
    """

    static let emptyResults = """
    {"results": [], "page": 1, "total_pages": 1}
    """
}

#endif
