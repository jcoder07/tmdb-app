//
//  RequestTokenResponse.swift
//  tmdb-app
//

import Foundation

struct RequestTokenResponse: Decodable {
    let success: Bool
    let expiresAt: String?
    let requestToken: String?
}
