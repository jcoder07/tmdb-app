import UIKit
import Observation
import TMDBCore

final class WatchlistViewController: UIViewController {

    private let viewModel: WatchlistViewModel

    // MARK: - UI

    private let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movies", "TV Shows"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = WatchlistErrorView()

    private var dataSource: UITableViewDiffableDataSource<Int, Int>!

    // MARK: - Init

    init(viewModel: WatchlistViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
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
        tableView.register(WatchlistItemCell.self, forCellReuseIdentifier: WatchlistItemCell.reuseID)
        dataSource = UITableViewDiffableDataSource(tableView: tableView) { [weak self] tableView, indexPath, itemID in
            let cell = tableView.dequeueReusableCell(withIdentifier: WatchlistItemCell.reuseID, for: indexPath) as! WatchlistItemCell
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

        // Empty state
        if !viewModel.isLoading && !hasError {
            let isEmpty = (viewModel.selectedTab == .movies && viewModel.movies.isEmpty)
                       || (viewModel.selectedTab == .tvShows && viewModel.tvShows.isEmpty)
            if isEmpty {
                let label = UILabel()
                label.text = viewModel.selectedTab == .movies ? "No movies in your watchlist" : "No TV shows in your watchlist"
                label.textColor = .secondaryLabel
                label.textAlignment = .center
                tableView.backgroundView = label
            } else {
                tableView.backgroundView = nil
            }
        }
    }
}

// MARK: - WatchlistItemCell

private final class WatchlistItemCell: UITableViewCell {

    static let reuseID = "WatchlistItemCell"

    private let posterView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 8
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()

    private let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.numberOfLines = 3
        return label
    }()

    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        let textStack = UIStackView(arrangedSubviews: [titleLabel, metaLabel, overviewLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [posterView, textStack])
        row.alignment = .top
        row.spacing = 12
        row.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(row)

        NSLayoutConstraint.activate([
            posterView.widthAnchor.constraint(equalToConstant: 60),
            posterView.heightAnchor.constraint(equalToConstant: 90),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, overview: String, posterURL: URL?, rating: Double, year: String?) {
        titleLabel.text = title
        overviewLabel.text = overview
        let star = "⭐ "
        let yearStr = year.map { "\($0)  " } ?? ""
        metaLabel.text = "\(yearStr)\(star)\(String(format: "%.1f", rating))"
        imageTask?.cancel()
        imageTask = posterView.loadImage(from: posterURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        posterView.image = nil
    }
}

// MARK: - WatchlistErrorView

private final class WatchlistErrorView: UIView {

    var message: String = "" { didSet { messageLabel.text = message } }
    var onRetry: (() -> Void)?
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
        icon.tintColor = .secondaryLabel
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40))
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        var config = UIButton.Configuration.plain()
        config.title = "Retry"
        config.baseForegroundColor = .systemRed
        let btn = UIButton(configuration: config)
        btn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [icon, messageLabel, btn])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
    @objc private func retryTapped() { onRetry?() }
}
