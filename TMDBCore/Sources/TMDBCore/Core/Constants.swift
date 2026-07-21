import Foundation

public struct Constants {

    private static let base = TMDBConfig.baseURL
    private static let key = TMDBConfig.apiKey

    public struct Urls {

        // MARK: - Authentication
        public static let requestToken = URL(string: "\(base)/authentication/token/new?api_key=\(key)")!
        public static let validateLogin = URL(string: "\(base)/authentication/token/validate_with_login?api_key=\(key)")!
        public static let createSession = URL(string: "\(base)/authentication/session/new?api_key=\(key)")!

        // MARK: - Account
        public static func account(sessionId: String) -> URL {
            URL(string: "\(base)/account?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func ratedMovies(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/rated/movies?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func ratedTVShows(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/rated/tv?api_key=\(key)&session_id=\(sessionId)")!
        }
        

        // MARK: - Account States & Actions
        public static func accountStates(movieId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/movie/\(movieId)/account_states?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func seriesAccountStates(seriesId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/tv/\(seriesId)/account_states?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func markFavorite(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/favorite?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func markWatchlist(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func accountLists(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/lists?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func addToList(listId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/list/\(listId)/add_item?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func removeFromList(listId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/list/\(listId)/remove_item?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func createList(sessionId: String) -> URL {
            URL(string: "\(base)/list?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func listItems(listId: Int) -> URL {
            URL(string: "\(base)/list/\(listId)?api_key=\(key)")!
        }

        public static func deleteList(listId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/list/\(listId)?api_key=\(key)&session_id=\(sessionId)")!
        }

        // MARK: - Favorites
        public static func favoriteMovies(accountId: Int, sessionId: String, page: Int = 1) -> URL {
            URL(string: "\(base)/account/\(accountId)/favorite/movies?api_key=\(key)&session_id=\(sessionId)&page=\(page)")!
        }

        public static func favoriteTVShows(accountId: Int, sessionId: String, page: Int = 1) -> URL {
            URL(string: "\(base)/account/\(accountId)/favorite/tv?api_key=\(key)&session_id=\(sessionId)&page=\(page)")!
        }

        // MARK: - Watchlist
        public static func watchlistMovies(accountId: Int, sessionId: String, page: Int = 1) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/movies?api_key=\(key)&session_id=\(sessionId)&page=\(page)")!
        }

        public static func watchlistTVShows(accountId: Int, sessionId: String, page: Int = 1) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/tv?api_key=\(key)&session_id=\(sessionId)&page=\(page)")!
        }

        // MARK: - Series
        public static func popularSeries(page: Int = 1) -> URL {
            URL(string: "\(base)/tv/popular?api_key=\(key)&page=\(page)")!
        }

        public static func seriesDetail(id: Int) -> URL {
            URL(string: "\(base)/tv/\(id)?api_key=\(key)")!
        }

        public static func seriesCredits(id: Int) -> URL {
            URL(string: "\(base)/tv/\(id)/credits?api_key=\(key)")!
        }

        public static func seriesReviews(id: Int) -> URL {
            URL(string: "\(base)/tv/\(id)/reviews?api_key=\(key)")!
        }

        // MARK: - Movies
        public static func popularMovies(page: Int = 1) -> URL {
            URL(string: "\(base)/movie/popular?api_key=\(key)&page=\(page)")!
        }

        public static func movieDetail(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)?api_key=\(key)")!
        }

        public static func movieCredits(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)/credits?api_key=\(key)")!
        }

        public static func movieReviews(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)/reviews?api_key=\(key)")!
        }

        public static func backdrop(path: String) -> URL? {
            URL(string: "https://image.tmdb.org/t/p/w780\(path)")
        }

        // MARK: - Genres
        public static let movieGenres = URL(string: "\(base)/genre/movie/list?api_key=\(key)")!
        public static let tvGenres = URL(string: "\(base)/genre/tv/list?api_key=\(key)")!

        // MARK: - Images
        public static func poster(path: String) -> URL? {
            URL(string: "https://image.tmdb.org/t/p/w185\(path)")
        }

        public static func gravatar(hash: String) -> URL {
            URL(string: "https://www.gravatar.com/avatar/\(hash)?s=185&d=404")!
        }
    }
}

 

