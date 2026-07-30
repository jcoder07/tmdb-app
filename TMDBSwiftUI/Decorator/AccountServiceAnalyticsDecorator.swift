//
//  AccountServiceAnalyticsDecorator.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 30-07-26.
//

import TMDBCore

final class AccountServiceAnalyticsDecorator: AccountServiceProtocol {
    private let decoratee: AccountServiceProtocol
    init(decoratee: AccountServiceProtocol) {
        self.decoratee = decoratee
    }
    func fetchAccountDetails(sessionId: String) async throws -> TMDBCore.AccountProfile {
        print("AccountServiceAnalyticsDecorator fetchAccountDetails")
        return try await decoratee.fetchAccountDetails(sessionId: sessionId)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [TMDBCore.RatedMovie] {
        print("AccountServiceAnalyticsDecorator fetchRatedMovies")
        return try await decoratee.fetchRatedMovies(accountId: accountId, sessionId: sessionId)
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [TMDBCore.RatedTVShow] {
        print("AccountServiceAnalyticsDecorator fetchRatedTVShows")
        return try await decoratee.fetchRatedTVShows(accountId: accountId, sessionId: sessionId)
    }
}
