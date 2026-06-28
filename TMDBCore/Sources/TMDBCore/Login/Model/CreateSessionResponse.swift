import Foundation

public struct CreateSessionResponse: Decodable {
    public let success: Bool
    public let sessionId: String
}
