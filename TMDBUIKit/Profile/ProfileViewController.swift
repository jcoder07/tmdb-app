import UIKit
import Observation
import TMDBCore

final class ProfileViewController: UIViewController {

    private let viewModel: ProfileViewModel
    private let onGoToWatchlist: () -> Void

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = ProfileErrorView()

    // Header
    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = UIColor(red: 0.024, green: 0.408, blue: 0.882, alpha: 1)
        iv.layer.cornerRadius = 40
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = .white
        return iv
    }()

    private let usernameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 20, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let movieScoreLabel = ScoreLabel(title: "Avg Movie Score")
    private let tvScoreLabel = ScoreLabel(title: "Avg TV Score")

    // Stats
    private let ratedMoviesLabel = StatLabel()
    private let ratedTVLabel = StatLabel()

    // Rating bars
    private let ratingBarsView = RatingBarsView()

    // Genres
    private let genresStack = UIStackView()

    private var imageTask: Task<Void, Never>?

    // MARK: - Init

    init(viewModel: ProfileViewModel, onGoToWatchlist: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onGoToWatchlist = onGoToWatchlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        setupNavBar()
        setupLayout()
        startObservationLoop()
        Task { await viewModel.load() }
    }

    // MARK: - Nav

    private func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "xmark.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(dismissTapped)
        )
    }

    @objc private func dismissTapped() { dismiss(animated: true) }

    // MARK: - Layout

    private func setupLayout() {
        // Header card with dark gradient background
        let headerCard = UIView()
        headerCard.backgroundColor = UIColor(red: 0.051, green: 0.145, blue: 0.251, alpha: 1)
        headerCard.layer.cornerRadius = 12

        let userRow = UIStackView(arrangedSubviews: [avatarView, usernameLabel])
        userRow.spacing = 16
        userRow.alignment = .center

        let scoreRow = UIStackView(arrangedSubviews: [movieScoreLabel, tvScoreLabel])
        scoreRow.distribution = .fillEqually
        scoreRow.spacing = 16

        let headerStack = UIStackView(arrangedSubviews: [userRow, scoreRow])
        headerStack.axis = .vertical
        headerStack.spacing = 16
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerCard.addSubview(headerStack)
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),
            headerStack.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerStack.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            headerStack.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -16),
        ])

        // Stats card
        let statsCard = makeCard {
            let row = UIStackView(arrangedSubviews: [ratedMoviesLabel, ratedTVLabel])
            row.distribution = .fillEqually
            row.spacing = 16
            return row
        }

        // Rating overview card
        let ratingCard = makeCard(title: "Rating Overview") { ratingBarsView }
        NSLayoutConstraint.activate([ratingBarsView.heightAnchor.constraint(equalToConstant: 100)])

        // Genres card
        genresStack.axis = .vertical
        genresStack.spacing = 8
        let genresCard = makeCard(title: "Most Watched Genres") { genresStack }

        // Go to watchlist
        var wlConfig = UIButton.Configuration.plain()
        wlConfig.title = "Go To Watchlist"
        wlConfig.baseForegroundColor = UIColor(red: 0.004, green: 0.706, blue: 0.894, alpha: 1)
        let watchlistBtn = UIButton(configuration: wlConfig)
        watchlistBtn.addTarget(self, action: #selector(watchlistTapped), for: .touchUpInside)

        // Logout button
        var logoutConfig = UIButton.Configuration.filled()
        logoutConfig.title = "Log Out"
        logoutConfig.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        logoutConfig.imagePlacement = .leading
        logoutConfig.baseBackgroundColor = .systemBackground
        logoutConfig.baseForegroundColor = .systemRed
        logoutConfig.cornerStyle = .medium
        let logoutBtn = UIButton(configuration: logoutConfig)
        logoutBtn.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)

        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)

        [headerCard, statsCard, ratingCard, genresCard, watchlistBtn, logoutBtn].forEach {
            contentStack.addArrangedSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])

        // Overlays
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
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

    private func makeCard(title: String? = nil, content: () -> UIView) -> UIView {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 12
        var views: [UIView] = []
        if let title {
            let header = UILabel()
            header.text = title
            header.font = .systemFont(ofSize: 15, weight: .semibold)
            header.textColor = .secondaryLabel
            views.append(header)
        }
        views.append(content())
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])
        return card
    }

    @objc private func watchlistTapped() { onGoToWatchlist() }
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
        })
        present(alert, animated: true)
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
        let isInitialLoad = viewModel.isLoading && viewModel.profile == nil
        activityIndicator.isHidden = !isInitialLoad
        isInitialLoad ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()

        let hasError = viewModel.errorMessage != nil && viewModel.profile == nil
        errorView.isHidden = !hasError
        errorView.message = viewModel.errorMessage ?? ""

        scrollView.isHidden = isInitialLoad || hasError

        guard let profile = viewModel.profile else { return }

        title = profile.username
        usernameLabel.text = profile.username

        if imageTask == nil {
            imageTask = avatarView.loadImage(from: profile.avatarURL)
        }

        movieScoreLabel.value = String(format: "%.0f%%", profile.avgMovieScore)
        tvScoreLabel.value = String(format: "%.0f%%", profile.avgTVScore)
        ratedMoviesLabel.configure(title: "Rated Movies", value: "\(profile.totalMovieRatings)")
        ratedTVLabel.configure(title: "Rated TV", value: "\(profile.totalTVRatings)")
        ratingBarsView.configure(with: profile.ratingDistribution, accentHex: profile.accentHex)

        genresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        profile.topGenres.prefix(5).forEach { genre in
            let row = GenreRowView(genre: genre)
            genresStack.addArrangedSubview(row)
        }
    }
}

// MARK: - ScoreLabel

private final class ScoreLabel: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    var value: String = "" { didSet { valueLabel.text = value } }

    init(title: String) {
        super.init(frame: .zero)
        valueLabel.font = .systemFont(ofSize: 22, weight: .bold)
        valueLabel.textColor = .white
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        titleLabel.numberOfLines = 2
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - StatLabel

private final class StatLabel: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        valueLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        titleLabel.textColor = .secondaryLabel
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
    }
}

// MARK: - RatingBarsView

private final class RatingBarsView: UIView {
    private var bars: [UIView] = []

    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with distribution: [RatingBar], accentHex: String) {
        bars.forEach { $0.removeFromSuperview() }
        bars = []
        let maxCount = distribution.map(\.count).max() ?? 1
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .bottom
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        let color = UIColor(hex: accentHex) ?? .systemBlue
        distribution.forEach { bar in
            let colStack = UIStackView()
            colStack.axis = .vertical
            colStack.alignment = .center
            colStack.spacing = 2
            let barView = UIView()
            barView.backgroundColor = color
            barView.layer.cornerRadius = 3
            let ratio = maxCount > 0 ? CGFloat(bar.count) / CGFloat(maxCount) : 0
            let heightConstraint = barView.heightAnchor.constraint(equalToConstant: max(4, 80 * ratio))
            heightConstraint.isActive = true
            barView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            let label = UILabel()
            label.text = "\(bar.rating)"
            label.font = .systemFont(ofSize: 9)
            label.textColor = .secondaryLabel
            colStack.addArrangedSubview(barView)
            colStack.addArrangedSubview(label)
            stack.addArrangedSubview(colStack)
            bars.append(barView)
        }
    }
}

// MARK: - GenreRowView

private final class GenreRowView: UIView {
    init(genre: GenreSlice) {
        super.init(frame: .zero)
        let colorSwatch = UIView()
        colorSwatch.backgroundColor = (UIColor(hex: genre.colorHex) ?? .systemBlue).withAlphaComponent(genre.opacity)
        colorSwatch.layer.cornerRadius = 3
        colorSwatch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colorSwatch.widthAnchor.constraint(equalToConstant: 14),
            colorSwatch.heightAnchor.constraint(equalToConstant: 14),
        ])
        let name = UILabel()
        name.text = genre.name
        name.font = .preferredFont(forTextStyle: .subheadline)
        let row = UIStackView(arrangedSubviews: [colorSwatch, name])
        row.spacing = 8
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ProfileErrorView

private final class ProfileErrorView: UIView {
    var message: String = "" { didSet { messageLabel.text = message } }
    var onRetry: (() -> Void)?
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
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

// MARK: - UIColor hex extension

private extension UIColor {
    convenience init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
