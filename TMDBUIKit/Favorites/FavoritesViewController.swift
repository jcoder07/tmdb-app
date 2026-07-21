import UIKit
import Observation
import TMDBCore

final class FavoritesViewController: UIViewController {

    private let viewModel: FavoritesViewModel

    // MARK: - UI

    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movies", "TV Shows"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = MediaErrorView()

    private var dataSource: UITableViewDiffableDataSource<Int, Int>!

    // MARK: - Init

    init(viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        setupDataSource()
        startObservationLoop()
        Task { await viewModel.load() }
    }

    // MARK: - Layout

    private func setupLayout() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none

        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        errorView.onRetry = { [weak self] in Task { await self?.viewModel.load() } }
    }

    private func setupDataSource() {
        tableView.register(MediaItemCell.self, forCellReuseIdentifier: MediaItemCell.reuseID)
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, itemID in
            let cell = tableView.dequeueReusableCell(withIdentifier: MediaItemCell.reuseID, for: indexPath) as! MediaItemCell
            guard let self else { return cell }
            switch self.viewModel.selectedTab {
            case .movies:
                if let movie = self.viewModel.movies.first(where: { $0.id == itemID }) {
                    cell.configure(
                        title: movie.title,
                        overview: movie.overview,
                        posterURL: movie.posterURL,
                        rating: movie.voteAverage,
                        year: movie.releaseDate.map { String($0.prefix(4)) }
                    )
                }
            case .tvShows:
                if let show = self.viewModel.tvShows.first(where: { $0.id == itemID }) {
                    cell.configure(
                        title: show.name,
                        overview: show.overview,
                        posterURL: show.posterURL,
                        rating: show.voteAverage,
                        year: show.firstAirDate.map { String($0.prefix(4)) }
                    )
                }
            }
            return cell
        }
    }

    @objc private func segmentChanged() {
        viewModel.selectedTab = segmentedControl.selectedSegmentIndex == 0 ? .movies : .tvShows
    }

    // MARK: - Observation

    private func startObservationLoop() {
        withObservationTracking {
            render()
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in self?.startObservationLoop() }
        }
    }

    private func render() {
        activityIndicator.isHidden = !viewModel.isLoading
        viewModel.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

        let hasError = viewModel.errorMessage != nil
        errorView.isHidden = !hasError
        errorView.message = viewModel.errorMessage ?? ""

        segmentedControl.isHidden = hasError || viewModel.isLoading
        tableView.isHidden = hasError || viewModel.isLoading

        segmentedControl.selectedSegmentIndex = viewModel.selectedTab == .movies ? 0 : 1

        var snapshot = NSDiffableDataSourceSnapshot<Int, Int>()
        snapshot.appendSections([0])
        switch viewModel.selectedTab {
        case .movies:
            snapshot.appendItems(viewModel.movies.map(\.id))
        case .tvShows:
            snapshot.appendItems(viewModel.tvShows.map(\.id))
        }
        dataSource.apply(snapshot, animatingDifferences: false)

        if !viewModel.isLoading && !hasError {
            let isEmpty = (viewModel.selectedTab == .movies && viewModel.movies.isEmpty)
                       || (viewModel.selectedTab == .tvShows && viewModel.tvShows.isEmpty)
            if isEmpty {
                let label = UILabel()
                label.text = viewModel.selectedTab == .movies ? "No movies in your favorites" : "No TV shows in your favorites"
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                tableView.backgroundView = label
            } else {
                tableView.backgroundView = nil
            }
        }
    }
}
