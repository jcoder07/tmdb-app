import Foundation

public enum TMDBConfig {
    public static let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    public static let baseURL = "https://api.themoviedb.org/3"
}
