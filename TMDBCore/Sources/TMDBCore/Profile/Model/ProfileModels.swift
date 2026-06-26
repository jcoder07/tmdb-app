import Foundation

// MARK: - Account

public struct AccountProfile {
    public let id: Int
    public let displayName: String
    public let avatarURL: URL?

    public init(id: Int, displayName: String, avatarURL: URL?) {
        self.id = id
        self.displayName = displayName
        self.avatarURL = avatarURL
    }
}

extension AccountProfile {
    init(_ dto: AccountProfileDTO) {
        id = dto.id
        displayName = dto.name.isEmpty ? dto.username : dto.name
        if let tmdbPath = dto.avatar.tmdb.avatarPath, !tmdbPath.isEmpty {
            avatarURL = Constants.Urls.poster(path: tmdbPath)
        } else {
            avatarURL = Constants.Urls.gravatar(hash: dto.avatar.gravatar.hash)
        }
    }
}

// MARK: - Rated Content

public struct RatedMovie {
    public let id: Int
    public let rating: Double
    public let genreIds: [Int]

    public init(id: Int, rating: Double, genreIds: [Int]) {
        self.id = id
        self.rating = rating
        self.genreIds = genreIds
    }
}

extension RatedMovie {
    init(_ dto: RatedMovieDTO) {
        id = dto.id
        rating = dto.rating
        genreIds = dto.genreIds
    }
}

public struct RatedTVShow {
    public let id: Int
    public let rating: Double
    public let genreIds: [Int]

    public init(id: Int, rating: Double, genreIds: [Int]) {
        self.id = id
        self.rating = rating
        self.genreIds = genreIds
    }
}

extension RatedTVShow {
    init(_ dto: RatedTVShowDTO) {
        id = dto.id
        rating = dto.rating
        genreIds = dto.genreIds
    }
}

// MARK: - Genre

public struct GenreItem {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

extension GenreItem {
    init(_ dto: GenreDTO) {
        id = dto.id
        name = dto.name
    }
}

// MARK: - UI / Presentation Models

public struct UserProfile {
    public let username: String
    public let avatarURL: URL?
    public let avgMovieScore: Double
    public let avgTVScore: Double
    public let totalMovieRatings: Int
    public let totalTVRatings: Int
    public let ratingDistribution: [RatingBar]
    public let topGenres: [GenreSlice]
    public let accentHex: String

    public init(
        username: String,
        avatarURL: URL?,
        avgMovieScore: Double,
        avgTVScore: Double,
        totalMovieRatings: Int,
        totalTVRatings: Int,
        ratingDistribution: [RatingBar],
        topGenres: [GenreSlice],
        accentHex: String
    ) {
        self.username = username
        self.avatarURL = avatarURL
        self.avgMovieScore = avgMovieScore
        self.avgTVScore = avgTVScore
        self.totalMovieRatings = totalMovieRatings
        self.totalTVRatings = totalTVRatings
        self.ratingDistribution = ratingDistribution
        self.topGenres = topGenres
        self.accentHex = accentHex
    }
}

public struct RatingBar: Identifiable {
    public let id = UUID()
    public let rating: Int
    public let count: Int

    public init(rating: Int, count: Int) {
        self.rating = rating
        self.count = count
    }
}

public struct GenreSlice: Identifiable {
    public let id = UUID()
    public let name: String
    public let colorHex: String
    public let opacity: Double
    public let percentage: Double

    public init(name: String, colorHex: String, opacity: Double, percentage: Double) {
        self.name = name
        self.colorHex = colorHex
        self.opacity = opacity
        self.percentage = percentage
    }
}
