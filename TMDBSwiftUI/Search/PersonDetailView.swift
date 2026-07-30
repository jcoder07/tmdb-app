import SwiftUI
import TMDBCore

struct PersonDetailView: View {
    var viewModel: PersonDetailViewModel
    let makeMovieDetailViewModel: ((Int) -> MovieDetailViewModel)?
    let makeSeriesDetailViewModel: ((Int) -> SeriesDetailViewModel)?

    init(
        viewModel: PersonDetailViewModel,
        makeMovieDetailViewModel: ((Int) -> MovieDetailViewModel)? = nil,
        makeSeriesDetailViewModel: ((Int) -> SeriesDetailViewModel)? = nil
    ) {
        self.viewModel = viewModel
        self.makeMovieDetailViewModel = makeMovieDetailViewModel
        self.makeSeriesDetailViewModel = makeSeriesDetailViewModel
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let message = viewModel.errorMessage {
                errorView(message: message)
            } else if let detail = viewModel.detail {
                content(detail: detail)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: SearchRoute.self) { route in
            switch route {
            case .movie(let id):
                if let factory = makeMovieDetailViewModel {
                    MovieDetailView(viewModel: factory(id))
                }
            case .series(let id):
                if let factory = makeSeriesDetailViewModel {
                    SeriesDetailView(viewModel: factory(id))
                }
            default:
                EmptyView()
            }
        }
        .task { await viewModel.load() }
    }

    private func content(detail: PersonDetail) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: photo + meta
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: detail.profileURL) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .overlay {
                                    Image(systemName: "person.crop.circle")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color(.systemGray3))
                                }
                        }
                    }
                    .frame(width: 110, height: 165)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 6) {
                        Text(detail.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .lineLimit(3)

                        if let dept = detail.knownForDepartment {
                            Label(dept, systemImage: "star")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        if let birthday = detail.birthday {
                            Label(birthday, systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        if let place = detail.placeOfBirth {
                            Label(place, systemImage: "mappin.and.ellipse")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }

                // Biography
                if !detail.biography.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Biography")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(detail.biography)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Known For — Movies
                if !viewModel.knownForMovies.isEmpty {
                    knownForSection(
                        title: "Known For (Movies)",
                        items: viewModel.knownForMovies.prefix(10).map { ($0.id, $0.title, $0.posterURL, SearchRoute.movie($0.id)) }
                    )
                }

                // Known For — TV
                if !viewModel.knownForSeries.isEmpty {
                    knownForSection(
                        title: "Known For (TV)",
                        items: viewModel.knownForSeries.prefix(10).map { ($0.id, $0.name, $0.posterURL, SearchRoute.series($0.id)) }
                    )
                }
            }
            .padding(16)
        }
    }

    private func knownForSection(title: String, items: [(Int, String, URL?, SearchRoute)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(items, id: \.0) { (_, itemTitle, posterURL, route) in
                        NavigationLink(value: route) {
                            VStack(alignment: .leading, spacing: 4) {
                                AsyncImage(url: posterURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable().scaledToFill()
                                    default:
                                        Rectangle().fill(Color(.systemGray5))
                                    }
                                }
                                .frame(width: 90, height: 135)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                                Text(itemTitle)
                                    .font(.caption2)
                                    .lineLimit(2)
                                    .frame(width: 90)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
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
