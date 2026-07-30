//
//  AccountServiceCacheDecorator.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 30-07-26.
//

import TMDBCore

actor AccountServiceCacheDecorator: AccountServiceProtocol {

    private let decoratee: any AccountServiceProtocol
    private var cachedProfile: AccountProfile?

    init(decoratee: any AccountServiceProtocol) {
        self.decoratee = decoratee
    }

    func fetchAccountDetails(sessionId: String) async throws -> AccountProfile {
        if let cached = cachedProfile {
            return cached
        }
        let profile = try await decoratee.fetchAccountDetails(sessionId: sessionId)
        cachedProfile = profile
        return profile
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [RatedMovie] {
        try await decoratee.fetchRatedMovies(accountId: accountId, sessionId: sessionId)
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [RatedTVShow] {
        try await decoratee.fetchRatedTVShows(accountId: accountId, sessionId: sessionId)
    }
}
