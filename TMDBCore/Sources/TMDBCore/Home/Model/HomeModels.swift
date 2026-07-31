import Foundation

// MARK: - Video

public struct Video: Identifiable, Sendable {
    public let id: String
    public let key: String
    public let site: String
    public let type: String
    public let official: Bool

    public init(id: String, key: String, site: String, type: String, official: Bool) {
        self.id = id
        self.key = key
        self.site = site
        self.type = type
        self.official = official
    }
}

extension Video {
    init(_ dto: VideoDTO) {
        id = dto.id
        key = dto.key
        site = dto.site
        type = dto.type
        official = dto.official
    }
}

// MARK: - Section Tab Enums

public enum TrendingTab: String, CaseIterable, Sendable {
    case today = "Today"
    case thisWeek = "This Week"
}

public enum TrailersTab: String, CaseIterable, Sendable {
    case popular = "Popular"
    case streaming = "Streaming"
    case onTV = "On TV"
    case forRent = "For Rent"
    case inTheaters = "In Theaters"
}

public enum PopularTab: String, CaseIterable, Sendable {
    case streaming = "Streaming"
    case onTV = "On TV"
    case forRent = "For Rent"
    case inTheaters = "In Theaters"
}

public enum FreeTab: String, CaseIterable, Sendable {
    case movies = "Movies"
    case tv = "TV"
}
