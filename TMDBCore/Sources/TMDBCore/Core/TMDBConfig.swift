import Foundation

public enum TMDBConfig {
    public static let apiKey = Bundle.main.infoDictionary?["TMDB_API_KEY"] as? String ?? ""
    public static let baseURL = Bundle.main.infoDictionary?["TMDB_BASE_URL"] as? String ?? ""
}
