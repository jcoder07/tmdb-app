//
//  AccountServiceLoggerDecorator.swift
//  TMDBSwiftUI
//
//  Created by Juan Fernandez on 30-07-26.
//

import TMDBCore

final class AccountServiceLoggerDecorator: AccountServiceProtocol {
    private let decoratee: AccountServiceProtocol
    init(decoratee: AccountServiceProtocol) {
        self.decoratee = decoratee
    }
    func fetchAccountDetails(sessionId: String) async throws -> TMDBCore.AccountProfile {
        print("AccountServiceLoggerDecorator fetchAccountDetails")
        return try await decoratee.fetchAccountDetails(sessionId: sessionId)
    }

    func fetchRatedMovies(accountId: Int, sessionId: String) async throws -> [TMDBCore.RatedMovie] {
        print("AccountServiceLoggerDecorator fetchRatedMovies")
        return try await decoratee.fetchRatedMovies(accountId: accountId, sessionId: sessionId)
    }

    func fetchRatedTVShows(accountId: Int, sessionId: String) async throws -> [TMDBCore.RatedTVShow] {
        print("AccountServiceLoggerDecorator fetchRatedTVShows")
        return try await decoratee.fetchRatedTVShows(accountId: accountId, sessionId: sessionId)
    }
}

