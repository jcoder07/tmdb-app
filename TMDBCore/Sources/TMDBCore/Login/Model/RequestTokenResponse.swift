import Foundation

public struct RequestTokenResponse: Decodable {
    public let success: Bool
    public let expiresAt: String?
    public let requestToken: String?
}
