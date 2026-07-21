import Foundation
import SwiftData
import TMDBCore

public final class SwiftDataSessionManager: SessionManagerProtocol {
    private let container: ModelContainer

    public init() {
        do {
            container = try ModelContainer(for: SessionEntry.self)
        } catch {
            fatalError("Failed to create SwiftData ModelContainer: \(error)")
        }
    }

    public func saveSession(id: String) {
        let context = ModelContext(container)
        try? context.delete(model: SessionEntry.self)
        context.insert(SessionEntry(sessionId: id))
        try? context.save()
    }

    public func getSession() -> String? {
        let context = ModelContext(container)
        var descriptor = FetchDescriptor<SessionEntry>()
        descriptor.fetchLimit = 1
        return (try? context.fetch(descriptor))?.first?.sessionId
    }

    public func clearSession() {
        let context = ModelContext(container)
        try? context.delete(model: SessionEntry.self)
        try? context.save()
    }

    public var isLoggedIn: Bool {
        getSession() != nil
    }
}
