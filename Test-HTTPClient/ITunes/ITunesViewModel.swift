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
    public var searchTerm: String = ""

    private let service: any ITunesServiceProtocol
    private var searchTask: Task<Void, Never>?

    public init(service: ITunesServiceProtocol) {
        self.service = service
    }

    public func search(immediate: Bool = false) {
        searchTask?.cancel()
        let term = searchTerm.trimmingCharacters(in: .whitespaces)
        guard !term.isEmpty else {
            tracks = []
            errorMessage = nil
            return
        }
        searchTask = Task {
            if !immediate {
                try? await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }
            }
            await performSearch(term: term)
        }
    }

    private func performSearch(term: String) async {
        isLoading = true
        errorMessage = nil
        do {
            tracks = try await service.fetchTrack(searchTerm: term)
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
