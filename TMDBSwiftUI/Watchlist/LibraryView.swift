import SwiftUI
import TMDBCore

struct LibraryView: View {
    let watchlistViewModel: WatchlistViewModel
    let favoritesViewModel: FavoritesViewModel

    @State private var selectedList: LibraryList = .watchlist

    enum LibraryList { case watchlist, favorites }

    var body: some View {
        VStack(spacing: 0) {
            Picker("List", selection: $selectedList) {
                Text("Watchlist").tag(LibraryList.watchlist)
                Text("Favorites").tag(LibraryList.favorites)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            switch selectedList {
            case .watchlist:
                WatchlistView(viewModel: watchlistViewModel)
            case .favorites:
                FavoritesView(viewModel: favoritesViewModel)
            }
        }
        .navigationTitle(selectedList == .watchlist ? "Watchlist" : "Favorites")
        .navigationBarTitleDisplayMode(.inline)
    }
}
