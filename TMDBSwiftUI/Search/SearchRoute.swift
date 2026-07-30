import TMDBCore

enum SearchRoute: Hashable {
    case movie(Int)
    case series(Int)
    case person(Int)
    case genre(GenreItem)
    case browse(BrowseKind)
}
