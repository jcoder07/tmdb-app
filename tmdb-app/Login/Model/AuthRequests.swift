//
//  AuthRequests.swift
//  tmdb-app
//

import Foundation

struct ValidateLoginRequest: Encodable {
    let username: String
    let password: String
    let requestToken: String
}

struct CreateSessionRequest: Encodable {
    let requestToken: String
}
