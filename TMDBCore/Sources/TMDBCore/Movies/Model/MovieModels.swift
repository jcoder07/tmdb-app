import Foundation

// MARK: - Popular Movie

public struct Movie: Identifiable {
    public let id: Int
    public let title: String
    public let posterURL: URL?
    public let voteAverage: Double
    public let releaseDate: String?

    public init(id: Int, title: String, posterURL: URL?, voteAverage: Double, releaseDate: String?) {
        self.id = id
        self.title = title
        self.posterURL = posterURL
        self.voteAverage = voteAverage
        self.releaseDate = releaseDate
    }
}

extension Movie {
    init(_ dto: PopularMovieDTO) {
        id = dto.id
        title = dto.title
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        voteAverage = dto.voteAverage
        releaseDate = dto.releaseDate
    }
}

// MARK: - Movies Page

public struct MoviesPage {
    public let movies: [Movie]
    public let page: Int
    public let totalPages: Int

    public init(movies: [Movie], page: Int, totalPages: Int) {
        self.movies = movies
        self.page = page
        self.totalPages = totalPages
    }
}

extension MoviesPage {
    init(_ dto: PopularMoviesResponseDTO) {
        movies = dto.results.map(Movie.init)
        page = dto.page
        totalPages = dto.totalPages
    }
}

// MARK: - Movie Detail

public struct MovieDetail: Identifiable {
    public let id: Int
    public let title: String
    public let overview: String
    public let backdropURL: URL?
    public let posterURL: URL?
    public let releaseDate: String?
    public let voteAverage: Double
    public let voteCount: Int
    public let runtime: Int?
    public let genres: [Genre]
    public let tagline: String?
    public let status: String?
    public let budget: Int?
    public let revenue: Int?

    public init(
        id: Int, title: String, overview: String,
        backdropURL: URL?, posterURL: URL?, releaseDate: String?,
        voteAverage: Double, voteCount: Int, runtime: Int?,
        genres: [Genre], tagline: String?, status: String?,
        budget: Int?, revenue: Int?
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.backdropURL = backdropURL
        self.posterURL = posterURL
        self.releaseDate = releaseDate
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.runtime = runtime
        self.genres = genres
        self.tagline = tagline
        self.status = status
        self.budget = budget
        self.revenue = revenue
    }
}

extension MovieDetail {
    init(_ dto: MovieDetailDTO) {
        id = dto.id
        title = dto.title
        overview = dto.overview
        backdropURL = dto.backdropPath.flatMap { Constants.Urls.backdrop(path: $0) }
        posterURL = dto.posterPath.flatMap { Constants.Urls.poster(path: $0) }
        releaseDate = dto.releaseDate
        voteAverage = dto.voteAverage
        voteCount = dto.voteCount
        runtime = dto.runtime
        genres = dto.genres.map(Genre.init)
        tagline = dto.tagline
        status = dto.status
        budget = dto.budget
        revenue = dto.revenue
    }
}

// MARK: - Genre

public struct Genre: Identifiable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

extension Genre {
    init(_ dto: MovieGenreDTO) {
        id = dto.id
        name = dto.name
    }
}

// MARK: - Cast

public struct CastMember: Identifiable {
    public let id: Int
    public let name: String
    public let character: String
    public let profileURL: URL?
    public let order: Int

    public init(id: Int, name: String, character: String, profileURL: URL?, order: Int) {
        self.id = id
        self.name = name
        self.character = character
        self.profileURL = profileURL
        self.order = order
    }
}

extension CastMember {
    init(_ dto: CastMemberDTO) {
        id = dto.id
        name = dto.name
        character = dto.character
        profileURL = dto.profilePath.flatMap { Constants.Urls.poster(path: $0) }
        order = dto.order
    }
}

// MARK: - Review

public struct Review: Identifiable {
    public let id: String
    public let author: String
    public let content: String
    public let createdAt: String?
    public let rating: Double?

    public init(id: String, author: String, content: String, createdAt: String?, rating: Double?) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.rating = rating
    }
}

extension Review {
    init(_ dto: ReviewDTO) {
        id = dto.id
        author = dto.author
        content = dto.content
        createdAt = dto.createdAt
        rating = dto.authorDetails?.rating
    }
}
