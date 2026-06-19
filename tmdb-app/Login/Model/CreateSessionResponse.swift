//
//  CreateSessionResponse.swift
//  tmdb-app
//

import Foundation

struct CreateSessionResponse: Decodable {
    let success: Bool
    let sessionId: String
}
