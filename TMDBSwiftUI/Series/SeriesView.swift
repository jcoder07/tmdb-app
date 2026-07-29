//
//  SeriesView.swift
//  tmdb-app
//

import SwiftUI
import TMDBCore

struct SeriesView: View {

    var viewModel: SeriesViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.series.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage, viewModel.series.isEmpty {
                SeriesErrorView(message: message) {
                    Task { await viewModel.load() }
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.displayedSeries) { show in
                            NavigationLink(value: show.id) {
                                SeriesCard(
                                    name: show.name,
                                    posterURL: show.posterURL,
                                    voteAverage: show.voteAverage
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                    if viewModel.canShowMore {
                        Button {
                            Task { await viewModel.showMore() }
                        } label: {
                            if viewModel.isLoadingMore {
                                ProgressView()
                                    .padding(.vertical, 20)
                            } else {
                                Text("Show More")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(hex: "01B4E4"))
                                    .padding(.vertical, 20)
                            }
                        }
                    }
                }
                .navigationDestination(for: Int.self) { seriesId in
                    SeriesDetailView(viewModel: makeSeriesDetailViewModel(seriesId))
                }
            }
        }
        .navigationTitle("Series")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }
}

// MARK: - SeriesErrorView

private struct SeriesErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                onRetry()
            } label: {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - SeriesCard

private struct SeriesCard: View {
    let name: String
    let posterURL: URL?
    let voteAverage: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: posterURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            Image(systemName: "tv")
                                .foregroundStyle(Color(.systemGray3))
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(2)
                .foregroundStyle(.primary)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
                Text(voteAverage, format: .number.precision(.fractionLength(1)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Previews

private struct MockSeriesService: SeriesServiceProtocol {
    var page: SeriesPage = SeriesPage(series: [], page: 1, totalPages: 1)
    var shouldFail = false
    var shouldHang = false

    func fetchPopularSeries(page: Int) async throws -> SeriesPage {
        if shouldHang { try await Task.sleep(nanoseconds: .max) }
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return self.page
    }
}

private struct MockSeriesDetailService: SeriesDetailServiceProtocol {
    func fetchSeriesDetail(id: Int) async throws -> SeriesDetail { fatalError("not used in preview") }
    func fetchCredits(id: Int) async throws -> [CastMember] { [] }
    func fetchReviews(id: Int) async throws -> [Review] { [] }
    func fetchAccountStates(seriesId: Int, sessionId: String) async throws -> (isFavorite: Bool, isInWatchlist: Bool) { (false, false) }
    func markFavorite(accountId: Int, seriesId: Int, sessionId: String, isFavorite: Bool) async throws {}
    func markWatchlist(accountId: Int, seriesId: Int, sessionId: String, inWatchlist: Bool) async throws {}
    func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList] { [] }
    func addToList(listId: Int, seriesId: Int, sessionId: String) async throws {}
}

private let sampleSeries: [Series] = [
    Series(id: 1, name: "Breaking Bad",    posterURL: nil, voteAverage: 9.5, firstAirDate: "2008-01-20"),
    Series(id: 2, name: "The Last of Us",  posterURL: nil, voteAverage: 8.8, firstAirDate: "2023-01-15"),
    Series(id: 3, name: "Chernobyl",       posterURL: nil, voteAverage: 9.4, firstAirDate: "2019-05-06"),
    Series(id: 4, name: "Severance",       posterURL: nil, voteAverage: 8.7, firstAirDate: "2022-02-18"),
]

@MainActor
private func makeViewModel(service: MockSeriesService) -> SeriesViewModel {
    SeriesViewModel(service: service)
}

private let previewDetailFactory: (Int) -> SeriesDetailViewModel = {
    SeriesDetailViewModel(seriesId: $0, service: MockSeriesDetailService())
}

#Preview("Content") {
    NavigationStack {
        SeriesView(
            viewModel: makeViewModel(service: MockSeriesService(
                page: SeriesPage(series: sampleSeries, page: 1, totalPages: 3)
            )),
            makeSeriesDetailViewModel: previewDetailFactory
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        SeriesView(
            viewModel: makeViewModel(service: MockSeriesService(shouldHang: true)),
            makeSeriesDetailViewModel: previewDetailFactory
        )
    }
}

#Preview("Error") {
    NavigationStack {
        SeriesView(
            viewModel: makeViewModel(service: MockSeriesService(shouldFail: true)),
            makeSeriesDetailViewModel: previewDetailFactory
        )
    }
}
