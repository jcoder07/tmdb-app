//
//  RequestTokenResponse.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 06-01-26.
//

import Foundation

struct RequestTokenResponse: Decodable {
    let success: Bool
    let expiresAt: String
    let requestToken: String

    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}
