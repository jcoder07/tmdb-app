//
//  ITunesService.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import Foundation
import TMDBCore

public protocol ITunesServiceProtocol: Sendable {
    func fetchTrack(searchTerm: String) async throws -> [ITunesTrack]
}

public final class ITunesService: ITunesServiceProtocol {
    
    private let httpClient: HttpClientProtocol
    
    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }
    
    public func fetchTrack(searchTerm: String) async throws -> [ITunesTrack] {
        
        let resource = Resource(url: ITunesEndpoints.Urls.searchTrack(term: searchTerm), modelType: ITunesResponseDTO.self)
        return try await httpClient.load(resource).results.map(ITunesTrack.init)
    }
}
