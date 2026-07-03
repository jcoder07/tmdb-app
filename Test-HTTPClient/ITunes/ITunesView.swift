//
//  ITunesView.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import SwiftUI
import TMDBCore

struct ITunesView: View {
    @Bindable var viewModel: ITunesViewModel

    var body: some View {
        content
            .navigationTitle("iTunes Search")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchTerm, prompt: "Search for music")
            .onChange(of: viewModel.searchTerm) {
                viewModel.search()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            ITunesErrorView(message: error) {
                viewModel.search(immediate: true)
            }
        } else if viewModel.searchTerm.trimmingCharacters(in: .whitespaces).isEmpty {
            ITunesEmptyView(label: "Search for music above", imageName: "magnifyingglass")
        } else if viewModel.tracks.isEmpty {
            ITunesEmptyView(label: "No results for \"\(viewModel.searchTerm)\"")
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
    var imageName: String = "music.note"

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: imageName)
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
    func fetchTrack(searchTerm: String) async throws -> [ITunesTrack] { [] }
}

@MainActor
private func previewViewModel(
    searchTerm: String = "",
    tracks: [ITunesTrack] = [],
    isLoading: Bool = false,
    errorMessage: String? = nil
) -> ITunesViewModel {
    let vm = ITunesViewModel(service: MockITunesService())
    vm.searchTerm = searchTerm
    vm.tracks = tracks
    vm.isLoading = isLoading
    vm.errorMessage = errorMessage
    return vm
}

private let sampleTracks: [ITunesTrack] = [
    ITunesTrack(trackId: 1, trackName: "Yellow", artistName: "Coldplay", artworkUrl100: nil),
    ITunesTrack(trackId: 2, trackName: "Fix You", artistName: "Coldplay", artworkUrl100: nil),
    ITunesTrack(trackId: 3, trackName: "The Scientist", artistName: "Coldplay", artworkUrl100: nil)
]

#Preview("Tracks") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(searchTerm: "Coldplay", tracks: sampleTracks))
    }
}

#Preview("Loading") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(searchTerm: "Coldplay", isLoading: true))
    }
}

#Preview("No Results") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(searchTerm: "xyzxyz"))
    }
}

#Preview("Error") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel(
            searchTerm: "Coldplay",
            errorMessage: "The Internet connection appears to be offline."
        ))
    }
}

#Preview("Empty") {
    NavigationStack {
        ITunesView(viewModel: previewViewModel())
    }
}
