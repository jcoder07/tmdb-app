//
//  SessionEntity.swift
//  TMDBSwiftUI
//
//  Created by Juan Fernandez on 07-07-26.
//

import Foundation
import TMDBCore
import CoreData


// MARK: - Managed Object

@objc(SessionEntity)
final class SessionEntity: NSManagedObject {
    @NSManaged var id: String?
}

// MARK: - Model Definition

extension SessionCoreDataStack {
    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "SessionEntity"
        entity.managedObjectClassName = NSStringFromClass(SessionEntity.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType
        idAttribute.isOptional = true

        entity.properties = [idAttribute]
        model.entities = [entity]

        return model
    }
}
