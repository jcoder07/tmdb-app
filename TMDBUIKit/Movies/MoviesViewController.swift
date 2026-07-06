import UIKit
import Observation
import TMDBCore

final class MoviesViewController: UIViewController {

    private let viewModel: MoviesViewModel

    // MARK: - UI

    private lazy var collectionView: UICollectionView = {
        UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
    }()

    private let activityIndicator = UIActivityIndicatorView(style: .large)

    private let errorView = MoviesErrorView()

    private let showMoreButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Show More"
        config.baseForegroundColor = UIColor(red: 0.004, green: 0.706, blue: 0.894, alpha: 1)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var transformedAttributes = attributes
            transformedAttributes.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return transformedAttributes
        }
        return UIButton(configuration: config)
    }()

    private var dataSource: UICollectionViewDiffableDataSource<String, Int>!

    // MARK: - Init

    init(viewModel: MoviesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Movies"
        view.backgroundColor = .systemBackground
        setupCollectionView()
        setupDataSource()
        setupOverlays()
        setupShowMore()
        startObservationLoop()
        Task { await viewModel.load() }
    }

    // MARK: - Layout

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .estimated(260))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(260))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 10, bottom: 16, trailing: 10)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<MovieCell, Int> { [weak self] cell, _, movieId in
            guard let movie = self?.viewModel.displayedMovies.first(where: { $0.id == movieId }) else { return }
            cell.configure(with: movie)
        }
        dataSource = UICollectionViewDiffableDataSource<String, Int>(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    private func setupOverlays() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.isHidden = true
        view.addSubview(activityIndicator)
        view.addSubview(errorView)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        errorView.onRetry = { [weak self] in Task { await self?.viewModel.load() } }
    }

    private func setupShowMore() {
        showMoreButton.translatesAutoresizingMaskIntoConstraints = false
        showMoreButton.backgroundColor = .systemBackground
        showMoreButton.isHidden = true
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
        view.addSubview(showMoreButton)
        NSLayoutConstraint.activate([
            showMoreButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            showMoreButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            showMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            showMoreButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func showMoreTapped() {
        Task { await viewModel.showMore() }
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
        let isInitialLoad = viewModel.isLoading && viewModel.movies.isEmpty
        let hasError = viewModel.errorMessage != nil && viewModel.movies.isEmpty

        activityIndicator.isHidden = !isInitialLoad
        isInitialLoad ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

        errorView.isHidden = !hasError
        errorView.message = viewModel.errorMessage ?? ""

        collectionView.isHidden = isInitialLoad || hasError

        let previousCount = dataSource.snapshot().numberOfItems
        var snapshot = NSDiffableDataSourceSnapshot<String, Int>()
        snapshot.appendSections(["main"])
        snapshot.appendItems(viewModel.displayedMovies.map(\.id))
        dataSource.apply(snapshot, animatingDifferences: false)

        updateFooter()

        // After pagination, scroll to the first new item so the user sees the new content.
        let newCount = snapshot.numberOfItems
        if newCount > previousCount && previousCount > 0 {
            let firstNewIndexPath = IndexPath(item: previousCount, section: 0)
            collectionView.scrollToItem(at: firstNewIndexPath, at: .top, animated: true)
        }
    }

    private func updateFooter() {
        let canShowMore = viewModel.canShowMore
        collectionView.contentInset.bottom = canShowMore ? 50 : 0

        if canShowMore {
            var config = showMoreButton.configuration
            config?.showsActivityIndicator = viewModel.isLoadingMore
            config?.title = viewModel.isLoadingMore ? nil : "Show More"
            showMoreButton.configuration = config
            // Force layout so contentSize is accurate before checking scroll position.
            collectionView.layoutIfNeeded()
        }
        updateShowMoreVisibility()
    }

    // Shows the button only when the user has scrolled to the bottom of the current results.
    private func updateShowMoreVisibility() {
        guard viewModel.canShowMore else {
            showMoreButton.isHidden = true
            return
        }
        let distanceToBottom = collectionView.contentSize.height
            - collectionView.contentOffset.y
            - collectionView.frame.height
        showMoreButton.isHidden = distanceToBottom > 40
    }
}

// MARK: - UICollectionViewDelegate

extension MoviesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.displayedMovies.count else { return }
        let movie = viewModel.displayedMovies[indexPath.item]
        let detailViewController = MovieDetailViewController(viewModel: viewModel.makeDetailViewModel(for: movie.id))
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateShowMoreVisibility()
    }
}

// MARK: - MovieCell

private final class MovieCell: UICollectionViewCell {

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.cornerRadius = 10
        return imageView
    }()

    private let filmIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "film"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.fontMetrics(for: .caption1)
        label.numberOfLines = 2
        return label
    }()

    private let starImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemYellow
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        return imageView
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption2)
        label.textColor = .secondaryLabel
        return label
    }()

    private var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupLayout() {
        let ratingStack = UIStackView(arrangedSubviews: [starImage, ratingLabel])
        ratingStack.spacing = 4
        ratingStack.alignment = .center

        let stack = UIStackView(arrangedSubviews: [posterImageView, titleLabel, ratingStack])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        posterImageView.addSubview(filmIcon)
        filmIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filmIcon.centerXAnchor.constraint(equalTo: posterImageView.centerXAnchor),
            filmIcon.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            filmIcon.widthAnchor.constraint(equalToConstant: 32),
            filmIcon.heightAnchor.constraint(equalToConstant: 32),
        ])

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 3.0 / 2.0),
        ])
    }

    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        ratingLabel.text = String(format: "%.1f", movie.voteAverage)
        imageTask?.cancel()
        filmIcon.isHidden = movie.posterURL != nil
        imageTask = posterImageView.loadImage(from: movie.posterURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        posterImageView.image = nil
        filmIcon.isHidden = false
    }
}

private extension UILabel {
    @discardableResult
    func fontMetrics(for style: UIFont.TextStyle) -> UILabel { self }
}

// MARK: - MoviesErrorView

private final class MoviesErrorView: UIView {

    var message: String = "" { didSet { messageLabel.text = message } }
    var onRetry: (() -> Void)?

    private let icon = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        icon.tintColor = .secondaryLabel
        icon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40))

        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        var config = UIButton.Configuration.plain()
        config.title = "Retry"
        config.baseForegroundColor = .systemRed
        retryButton.configuration = config
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, messageLabel, retryButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc private func retryTapped() { onRetry?() }
}
