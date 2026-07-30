import Foundation

// MARK: - Browse Kind

public enum BrowseKind: Hashable, Sendable {
    case movies
    case tv
    case people
}

// MARK: - Person Summary

public struct PersonSummary: Identifiable, Sendable {
    public let id: Int
    public let name: String
    public let profileURL: URL?
    public let knownForText: String

    public init(id: Int, name: String, profileURL: URL?, knownForText: String) {
        self.id = id
        self.name = name
        self.profileURL = profileURL
        self.knownForText = knownForText
    }
}

extension PersonSummary {
    init?(_ dto: MultiSearchItemDTO) {
        guard dto.mediaType == "person" else { return nil }
        id = dto.id
        name = dto.name ?? ""
        profileURL = dto.profilePath.flatMap { Constants.Urls.profile(path: $0) }
        let titles = (dto.knownFor ?? []).compactMap { $0.title ?? $0.name }
        knownForText = titles.prefix(2).joined(separator: ", ")
    }

    init(_ dto: PopularPersonDTO) {
        id = dto.id
        name = dto.name
        profileURL = dto.profilePath.flatMap { Constants.Urls.profile(path: $0) }
        let titles = dto.knownFor.compactMap { $0.title ?? $0.name }
        knownForText = titles.prefix(2).joined(separator: ", ")
    }
}

// MARK: - Search Result

public enum SearchResult: Identifiable, Sendable {
    case movie(Movie)
    case series(Series)
    case person(PersonSummary)

    public var id: String {
        switch self {
        case .movie(let m):  return "movie-\(m.id)"
        case .series(let s): return "series-\(s.id)"
        case .person(let p): return "person-\(p.id)"
        }
    }
}

extension SearchResult {
    init?(_ dto: MultiSearchItemDTO) {
        switch dto.mediaType {
        case "movie":
            guard let title = dto.title else { return nil }
            self = .movie(Movie(
                id: dto.id,
                title: title,
                posterURL: dto.posterPath.flatMap { Constants.Urls.poster(path: $0) },
                voteAverage: dto.voteAverage ?? 0,
                releaseDate: dto.releaseDate
            ))
        case "tv":
            guard let name = dto.name else { return nil }
            self = .series(Series(
                id: dto.id,
                name: name,
                posterURL: dto.posterPath.flatMap { Constants.Urls.poster(path: $0) },
                voteAverage: dto.voteAverage ?? 0,
                firstAirDate: dto.firstAirDate
            ))
        case "person":
            guard let summary = PersonSummary(dto) else { return nil }
            self = .person(summary)
        default:
            return nil
        }
    }
}
