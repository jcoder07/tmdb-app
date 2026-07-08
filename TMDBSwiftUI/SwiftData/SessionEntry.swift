import SwiftData

@Model
final class SessionEntry {
    var sessionId: String

    init(sessionId: String) {
        self.sessionId = sessionId
    }
}
