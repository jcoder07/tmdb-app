//
//  SessionCoreDataStack.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-07-26.
//

import Foundation
import TMDBCore
import CoreData

public final class SessionCoreDataStack: Sendable {
    let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(
            name: "SessionModel",
            managedObjectModel: Self.makeModel()
        )
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data store failed to load: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
