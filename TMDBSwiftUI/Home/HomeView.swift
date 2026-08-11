import SwiftUI
import TMDBCore

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    let profileViewModel: ProfileViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel
    let onGoToWatchlist: () -> Void

    @Environment(\.openURL) private var openURL
    @State private var showingProfile = false

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.trendingItems.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage, viewModel.trendingItems.isEmpty {
                errorView(message: message)
            } else {
                mainContent
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { showingProfile = true } label: {
                    Image(systemName: "person.circle.fill").imageScale(.large)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileView(viewModel: profileViewModel, onGoToWatchlist: {
                showingProfile = false
                onGoToWatchlist()
            })
        }
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .movie(let id):
                MovieDetailView(viewModel: makeMovieDetailViewModel(id))
            case .series(let id):
                SeriesDetailView(viewModel: makeSeriesDetailViewModel(id))
            default:
                EmptyView()
            }
        }
        .task { await viewModel.load() }
        .onChange(of: viewModel.trendingTab) { Task { await viewModel.loadTrending() } }
        .onChange(of: viewModel.trailersTab) { Task { await viewModel.loadTrailers() } }
        .onChange(of: viewModel.popularTab) { Task { await viewModel.loadPopular() } }
        .onChange(of: viewModel.freeTab) { Task { await viewModel.loadFree() } }
    }

    // MARK: - Main content

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                trendingSection
                trailersSection
                popularSection
                freeSection
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Trending

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Trending")
            sectionPicker(selection: $viewModel.trendingTab)
            if viewModel.trendingItems.isEmpty {
                sectionPlaceholder
            } else {
                PosterRail(items: viewModel.trendingItems)
            }
        }
    }

    // MARK: - Latest Trailers

    private var trailersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Latest Trailers")
            sectionPicker(selection: $viewModel.trailersTab)
            if viewModel.trailerItems.isEmpty {
                sectionPlaceholder
            } else {
                TrailerRail(
                    items: viewModel.trailerItems,
                    trailerKeys: viewModel.trailerKeys,
                    onPlayTap: { key in
                        if let url = URL(string: "https://www.youtube.com/watch?v=\(key)") {
                            openURL(url)
                        }
                    },
                    onCardAppear: { result in
                        Task { await viewModel.loadTrailerKey(for: result) }
                    }
                )
            }
        }
    }

    // MARK: - What's Popular

    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("What's Popular")
            sectionPicker(selection: $viewModel.popularTab)
            if viewModel.popularItems.isEmpty {
                sectionPlaceholder
            } else {
                PosterRail(items: viewModel.popularItems)
            }
        }
    }

    // MARK: - Free To Watch

    private var freeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Free To Watch")
            sectionPicker(selection: $viewModel.freeTab)
            if viewModel.freeItems.isEmpty {
                sectionPlaceholder
            } else {
                PosterRail(items: viewModel.freeItems)
            }
        }
    }

    // MARK: - Reusable sub-views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.title2)
            .fontWeight(.bold)
            .padding(.horizontal, 16)
    }

    private func sectionPicker<T: RawRepresentable & Hashable & CaseIterable>(
        selection: Binding<T>
    ) -> some View where T.RawValue == String, T.AllCases: RandomAccessCollection {
        Picker("", selection: selection) {
            ForEach(Array(T.allCases), id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 16)
    }

    private var sectionPlaceholder: some View {
        ProgressView()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button {
                Task { await viewModel.load() }
            } label: {
                Text("Retry")
                    .fontWeight(.semibold)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
