//
//  UITestCatalog.swift
//  TMDBSwiftUIUITests
//

import Foundation

/// Mirrors the id/title tables in `TMDBSwiftUI/UITestSupport/UITestFixtures.swift`.
///
/// UI tests run out-of-process and drive the app only through the accessibility tree, so they
/// can't import the app's fixtures directly — these literals are the single point to update if
/// the app-side catalog changes.
enum UITestCatalog {

    static let moviesPageOne = [1101, 1102, 1103, 1104]
    static let moviesPageTwo = [1105, 1106]
    static let popularSeries = [2201, 2202, 2203]
    static let trendingMovieID = 1101
    static let trendingSeriesID = 2201

    static let searchMovieID = 1701
    static let searchSeriesID = 2601
    static let searchPersonID = 3401

    static let movieTitles: [Int: String] = [
        1101: "Arrival Protocol",
        1102: "Neon Harbor",
        1103: "The Quiet Ledger",
        1104: "Ashfall",
        1105: "Glass Meridian",
        1106: "Salt and Static",
        1701: "Searched Feature"
    ]

    static let seriesTitles: [Int: String] = [
        2201: "Harbor Lights",
        2202: "The Long Winter",
        2203: "Cinder Court",
        2601: "Searched Series"
    ]

    static let personNames: [Int: String] = [
        3401: "Ada Fixture"
    ]

    static let searchQueryWithResults = "harbor"
    static let searchQueryWithoutResults = "zzzznotfound"

    static func movieTitle(_ id: Int) -> String { movieTitles[id] ?? "Movie \(id)" }
    static func seriesTitle(_ id: Int) -> String { seriesTitles[id] ?? "Series \(id)" }
    static func personName(_ id: Int) -> String { personNames[id] ?? "Person \(id)" }
}
