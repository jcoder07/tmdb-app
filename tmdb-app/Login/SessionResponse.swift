//
//  SessionResponse.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import Foundation

struct SessionResponse: Decodable {
    let success: Bool
    let sessionId: String?

    enum CodingKeys: String, CodingKey {
        case success
        case sessionId = "session_id"
    }
}
