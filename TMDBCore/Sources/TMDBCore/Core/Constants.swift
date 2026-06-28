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

        // MARK: - Watchlist
        public static func watchlistMovies(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/movies?api_key=\(key)&session_id=\(sessionId)")!
        }

        public static func watchlistTVShows(accountId: Int, sessionId: String) -> URL {
            URL(string: "\(base)/account/\(accountId)/watchlist/tv?api_key=\(key)&session_id=\(sessionId)")!
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
