//
//  CoreDataSessionManager.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-07-26.
//

import Foundation
import TMDBCore
import CoreData

public final class CoreDataSessionManager: SessionManagerProtocol {
    private let stack: SessionCoreDataStack

    public init(stack: SessionCoreDataStack) {
        self.stack = stack
    }

    private var context: NSManagedObjectContext {
        stack.container.viewContext
    }

    public func saveSession(id: String) {
        context.performAndWait {
            // Borra cualquier sesión previa (solo debe existir una)
            let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
            if let existing = try? context.fetch(request) {
                existing.forEach(context.delete)
            }
            let entity = SessionEntity(context: context)
            entity.id = id
            try? context.save()
        }
    }

    public func getSession() -> String? {
        var result: String?
        context.performAndWait {
            let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
            request.fetchLimit = 1
            result = try? context.fetch(request).first?.id
        }
        return result
    }

    public func clearSession() {
        context.performAndWait {
            let request = NSFetchRequest<SessionEntity>(entityName: "SessionEntity")
            if let existing = try? context.fetch(request) {
                existing.forEach(context.delete)
                try? context.save()
            }
        }
    }

    public var isLoggedIn: Bool {
        getSession() != nil
    }
}
