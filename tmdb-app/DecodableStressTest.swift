//
//  decodable_stress_test.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 05-01-26.
//

import Foundation

struct DecodableStressTest: Codable {
    let id: Int
    let uuid: UUID
    let name: String
    let isActive: Bool
    let createdAt: Date
    let rating: Double
    let views: Int
    let optionalField: String?
    let status: Status
    let priority: Int
    let tags: [String]
    let metadata: Metadata
    let statistics: Statistics
    let users: [User]
    let settingsMap: [String: Bool]
    let dynamicValues: DynamicValues
    let emptyArray: [String]
    let emptyObject: [String: String]
    let coordinates: [Double]
    
}

enum Status: String, Codable {
    case approved
    case pending
    case rejected
}

struct Metadata: Codable {
    let source: String
    let version: String
    let debug: Bool
}

struct Statistics: Codable {
    let likes: Int
    let dislikes: Int
    let ratios: Ratios
}

struct Ratios: Codable {
    let likeRatio: Double
    let dislikeRatio: Double
}

struct User: Codable {
    let id: Int
    let username: String
    let role: UserRole
    let lastLogin: Date?
    let preferences: Preferences
}

enum UserRole: String, Codable {
    case admin
    case user
}

struct Preferences: Codable {
    let notifications: Bool
    let theme: String

    enum CodingKeys: String, CodingKey {
        case notifications
        case theme
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Decode theme normally
        self.theme = try container.decode(String.self, forKey: .theme)

        // Decode notifications from multiple possible types
        if let boolValue = try? container.decode(Bool.self, forKey: .notifications) {
            self.notifications = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .notifications) {
            self.notifications = intValue != 0
        } else if let stringValue = try? container.decode(String.self, forKey: .notifications) {
            self.notifications = (stringValue as NSString).boolValue
        } else {
            throw DecodingError.typeMismatch(
                Bool.self,
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Expected Bool, Int, or String for notifications"
                )
            )
        }
    }
}


struct DynamicValues: Codable {
    let stringValue: String
    let intValue: Int
    let doubleValue: Double
    let boolValue: Bool
    let nullValue: String?
}


