//
//  ITunesViewModel.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import Foundation
import Observation
import TMDBCore

@MainActor
@Observable
public final class ITunesViewModel {

    public var tracks: [ITunesTrack] = []
    public var isLoading = false
    public var errorMessage: String?

    private let service: any ITunesServiceProtocol

    public init(service: ITunesServiceProtocol) {
        self.service = service
    }

    public func load() async {
        isLoading = true
        errorMessage = nil
        do {
            tracks = try await service.fetchTrack(searchTerm: "Eminem")
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}


