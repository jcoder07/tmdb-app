//
//  ContentView.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

//
//  ITunesView.swift
//  Test-HTTPClient

import SwiftUI
import TMDBCore

struct ITunesView: View {
    var viewModel: ITunesViewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                ITunesErrorView(message: error) {
                    Task { await viewModel.load() }
                }
            } else {
                ITunesContentView(viewModel: viewModel)
            }
        }
        .navigationTitle("iTunes Search")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

private struct ITunesContentView: View {
    @Bindable var viewModel: ITunesViewModel

    var body: some View {
        if viewModel.tracks.isEmpty {
            ITunesEmptyView(label: "No tracks found")
        } else {
            List(viewModel.tracks) { track in
                ITunesTrackRow(
                    trackName: track.trackName,
                    artistName: track.artistName,
                    artworkURL: track.artworkURL
                )
            }
            .listStyle(.plain)
        }
    }
}

private struct ITunesTrackRow: View {
    let trackName: String?
    let artistName: String?
    let artworkURL: URL?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ArtworkImage(url: artworkURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(trackName ?? "Unknown")
                    .font(.headline)
                    .lineLimit(2)
                Text(artistName ?? "Unknown")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct ArtworkImage: View {
    let url: URL?

    var body: some View {
        AsyncImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .foregroundStyle(.quaternary)
        }
        .frame(width: 60, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ITunesEmptyView: View {
    let label: LocalizedStringKey

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "music.note")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(label)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ITunesErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Retry", action: onRetry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

private nonisolated struct MockITunesService: ITunesServiceProtocol {
    var trackResults: [ITunesTrack] = []
    var shouldFail = false
    var shouldHang = false

    func fetchTrack(searchTerm: String) async throws -> [ITunesTrack] {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return trackResults
    }
}

@MainActor
private func previewViewModel(
    service: MockITunesService = MockITunesService()
) -> ITunesViewModel {
    ITunesViewModel(service: service)
}

private let sampleTracks: [ITunesTrack] = [
    ITunesTrack(trackId: 1, trackName: "Yellow", artistName: "Coldplay", artworkUrl100: nil),
    ITunesTrack(trackId: 2, trackName: "Fix You", artistName: "Coldplay", artworkUrl100: nil),
    ITunesTrack(trackId: 3, trackName: "The Scientist", artistName: "Coldplay", artworkUrl100: nil)
]

#Preview("Tracks") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(
            service: MockITunesService(trackResults: sampleTracks)
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(
            service: MockITunesService(shouldHang: true)
        ))
    }
}

#Preview("Empty") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel())
    }
}

#Preview("Error") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(
            service: MockITunesService(shouldFail: true)
        ))
    }
}
