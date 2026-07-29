import SwiftUI
import TMDBCore

enum MyStuffDestination: Hashable {
    case favoriteMovies
    case favoriteTVShows
    case watchlistMovies
    case watchlistTVShows
    case listMovies(listId: Int)
    case listTVShows(listId: Int)
    case movieDetail(id: Int)
    case seriesDetail(id: Int)
}

struct MyStuffView: View {
    let watchlistViewModel: WatchlistViewModel
    let favoritesViewModel: FavoritesViewModel
    let myStuffViewModel: MyStuffViewModel
    let moviesViewModel: MoviesViewModel
    let seriesViewModel: SeriesViewModel
    let makeMovieDetailViewModel: (Int) -> MovieDetailViewModel
    let makeSeriesDetailViewModel: (Int) -> SeriesDetailViewModel

    @State private var showAddListSheet = false
    @State private var newListName = ""
    @State private var listToRename: UserList?
    @State private var renameText = ""

    var body: some View {
        List {
            Section {
                NavigationLink(value: MyStuffDestination.favoriteMovies) {
                    Label("Movies", systemImage: "film")
                }
                NavigationLink(value: MyStuffDestination.favoriteTVShows) {
                    Label("TV Series", systemImage: "tv")
                }
            } header: {
                Text("Favorites").textCase(nil)
            }

            Section {
                NavigationLink(value: MyStuffDestination.watchlistMovies) {
                    Label("Movies", systemImage: "film")
                }
                NavigationLink(value: MyStuffDestination.watchlistTVShows) {
                    Label("TV Series", systemImage: "tv")
                }
            } header: {
                Text("Watchlist").textCase(nil)
            }

            ForEach(myStuffViewModel.userLists) { list in
                Section {
                    NavigationLink(value: MyStuffDestination.listMovies(listId: list.id)) {
                        Label("Movies", systemImage: "film")
                    }
                    NavigationLink(value: MyStuffDestination.listTVShows(listId: list.id)) {
                        Label("TV Series", systemImage: "tv")
                    }
                } header: {
                    UserListSectionHeader(
                        name: myStuffViewModel.displayName(for: list),
                        onRename: {
                            renameText = myStuffViewModel.displayName(for: list)
                            listToRename = list
                        },
                        onDelete: {
                            Task { await myStuffViewModel.deleteList(listId: list.id) }
                        }
                    )
                }
            }
        }
        .navigationTitle("My Stuff")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newListName = ""
                    showAddListSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationDestination(for: MyStuffDestination.self) { destination in
            switch destination {
            case .favoriteMovies, .favoriteTVShows, .watchlistMovies, .watchlistTVShows,
                 .listMovies, .listTVShows:
                MyStuffDetailView(
                    destination: destination,
                    watchlistViewModel: watchlistViewModel,
                    favoritesViewModel: favoritesViewModel,
                    myStuffViewModel: myStuffViewModel,
                    moviesViewModel: moviesViewModel,
                    seriesViewModel: seriesViewModel
                )
            case .movieDetail(let id):
                MovieDetailView(viewModel: makeMovieDetailViewModel(id))
            case .seriesDetail(let id):
                SeriesDetailView(viewModel: makeSeriesDetailViewModel(id))
            }
        }
        .sheet(isPresented: $showAddListSheet) {
            AddListSheet(name: $newListName) { name in
                Task { await myStuffViewModel.createList(name: name) }
            }
        }
        .alert("Rename List", isPresented: Binding(
            get: { listToRename != nil },
            set: { if !$0 { listToRename = nil } }
        )) {
            TextField("List name", text: $renameText)
            Button("Save") {
                if let list = listToRename {
                    let trimmed = renameText.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        myStuffViewModel.setLocalName(trimmed, for: list.id)
                    }
                }
                listToRename = nil
            }
            Button("Cancel", role: .cancel) {
                listToRename = nil
            }
        }
        .task { await myStuffViewModel.load() }
        .refreshable { await myStuffViewModel.load() }
    }
}

private struct UserListSectionHeader: View {
    let name: String
    let onRename: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text(name).textCase(nil)
            Spacer()
            Menu {
                Button(action: onRename) {
                    Label("Rename", systemImage: "pencil")
                }
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct AddListSheet: View {
    @Binding var name: String
    let onAdd: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("List name", text: $name)
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        onAdd(name.trimmingCharacters(in: .whitespaces))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
