import UIKit
import Observation
import TMDBCore

final class MovieDetailViewController: UIViewController {

    private let viewModel: MovieDetailViewModel

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let errorView = DetailErrorView()

    // Header
    private let backdropImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        return iv
    }()
    private let closeButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "xmark")
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.5)
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        return UIButton(configuration: config)
    }()

    // Info
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .bold)
        l.numberOfLines = 0
        return l
    }()
    private let genresLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .subheadline)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        return l
    }()
    private let taglineLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .callout)
        l.textColor = .secondaryLabel
        l.fontMetrics()
        l.numberOfLines = 0
        l.textAlignment = .center
        return l
    }()
    private let overviewLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .body)
        l.numberOfLines = 0
        return l
    }()

    // Score
    private let scoreLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 34, weight: .bold)
        l.textAlignment = .center
        return l
    }()
    private let voteCountLabel: UILabel = {
        let l = UILabel()
        l.font = .preferredFont(forTextStyle: .caption1)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    // Cast
    private let castScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()
    private let castStack = UIStackView()

    // Reviews
    private let reviewsStack = UIStackView()

    private var imageTask: Task<Void, Never>?

    // MARK: - Init

    init(viewModel: MovieDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
        startObservationLoop()
        Task { await viewModel.load() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Layout

    private func setupLayout() {
        // Scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Backdrop
        backdropImageView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(backdropImageView)
        NSLayoutConstraint.activate([
            backdropImageView.heightAnchor.constraint(equalTo: backdropImageView.widthAnchor, multiplier: 9.0 / 16.0),
        ])

        // Close button
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36),
        ])

        // Info card
        let infoCard = makeCard {
            let stack = UIStackView(arrangedSubviews: [titleLabel, genresLabel, overviewLabel])
            stack.axis = .vertical
            stack.spacing = 8
            return stack
        }
        contentStack.addArrangedSubview(infoCard)
        contentStack.setCustomSpacing(12, after: backdropImageView)

        // Score card
        let scoreCard = makeCard {
            let scoreStack = UIStackView(arrangedSubviews: [scoreLabel, voteCountLabel])
            scoreStack.axis = .vertical
            scoreStack.spacing = 4
            scoreStack.alignment = .center
            let tagStack = UIStackView(arrangedSubviews: [scoreStack, taglineLabel])
            tagStack.axis = .vertical
            tagStack.spacing = 12
            tagStack.alignment = .center
            return tagStack
        }
        contentStack.addArrangedSubview(scoreCard)
        contentStack.setCustomSpacing(12, after: infoCard)

        // Cast card
        castStack.axis = .horizontal
        castStack.spacing = 12
        castScrollView.translatesAutoresizingMaskIntoConstraints = false
        castStack.translatesAutoresizingMaskIntoConstraints = false
        castScrollView.addSubview(castStack)
        NSLayoutConstraint.activate([
            castStack.topAnchor.constraint(equalTo: castScrollView.topAnchor),
            castStack.leadingAnchor.constraint(equalTo: castScrollView.leadingAnchor),
            castStack.trailingAnchor.constraint(equalTo: castScrollView.trailingAnchor),
            castStack.bottomAnchor.constraint(equalTo: castScrollView.bottomAnchor),
            castStack.heightAnchor.constraint(equalTo: castScrollView.heightAnchor),
        ])
        let castCard = makeCard(title: "Cast") { castScrollView }
        NSLayoutConstraint.activate([castScrollView.heightAnchor.constraint(equalToConstant: 120)])
        contentStack.addArrangedSubview(castCard)
        contentStack.setCustomSpacing(12, after: scoreCard)

        // Reviews card
        reviewsStack.axis = .vertical
        reviewsStack.spacing = 12
        let reviewsCard = makeCard(title: "Social") { reviewsStack }
        contentStack.addArrangedSubview(reviewsCard)
        contentStack.setCustomSpacing(12, after: castCard)
        contentStack.setCustomSpacing(40, after: reviewsCard)

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
            header.font = .systemFont(ofSize: 17, weight: .semibold)
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

    @objc private func closeTapped() { navigationController?.popViewController(animated: true) }

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
        errorView.isHidden = viewModel.errorMessage == nil
        errorView.message = viewModel.errorMessage ?? ""
        scrollView.isHidden = viewModel.isLoading || viewModel.errorMessage != nil

        guard let detail = viewModel.detail else { return }

        titleLabel.text = detail.title
        genresLabel.text = detail.genres.map(\.name).joined(separator: " · ")
        overviewLabel.text = detail.overview
        taglineLabel.text = detail.tagline.map { "\"\($0)\"" }
        taglineLabel.isHidden = detail.tagline == nil || detail.tagline?.isEmpty == true
        scoreLabel.text = "\(Int(detail.voteAverage * 10))%"
        voteCountLabel.text = "\(detail.voteCount) ratings"

        if backdropImageView.image == nil {
            imageTask = backdropImageView.loadImage(from: detail.backdropURL ?? detail.posterURL)
        }

        // Cast
        castStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        viewModel.displayedCast.forEach { member in
            castStack.addArrangedSubview(CastMemberView(member: member))
        }
        if viewModel.cast.count > 6 {
            let btn = UIButton(type: .system)
            btn.setTitle(viewModel.showFullCast ? "Show less" : "Show full cast", for: .normal)
            btn.addAction(UIAction { [weak self] _ in
                self?.viewModel.showFullCast.toggle()
            }, for: .touchUpInside)
            castStack.addArrangedSubview(btn)
        }

        // Reviews
        reviewsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if viewModel.reviews.isEmpty {
            let l = UILabel()
            l.text = "No reviews yet."
            l.textColor = .secondaryLabel
            l.font = .preferredFont(forTextStyle: .subheadline)
            reviewsStack.addArrangedSubview(l)
        } else {
            viewModel.reviews.forEach { review in
                reviewsStack.addArrangedSubview(ReviewCardView(review: review))
            }
        }
    }
}

// MARK: - CastMemberView

private final class CastMemberView: UIView {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray5
        iv.layer.cornerRadius = 24
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.numberOfLines = 2
        l.textAlignment = .center
        return l
    }()

    private let characterLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 10)
        l.textColor = .secondaryLabel
        l.numberOfLines = 2
        l.textAlignment = .center
        return l
    }()

    private var imageTask: Task<Void, Never>?

    init(member: CastMember) {
        super.init(frame: .zero)
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, characterLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48),
            widthAnchor.constraint(equalToConstant: 72),
        ])
        nameLabel.text = member.name
        characterLabel.text = member.character
        imageTask = imageView.loadImage(from: member.profileURL)
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ReviewCardView

private final class ReviewCardView: UIView {

    init(review: Review) {
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground
        layer.cornerRadius = 8

        let author = UILabel()
        author.text = review.author
        author.font = .systemFont(ofSize: 14, weight: .semibold)

        let content = UILabel()
        content.text = review.content
        content.font = .preferredFont(forTextStyle: .callout)
        content.numberOfLines = 4

        let stack = UIStackView(arrangedSubviews: [author, content])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - DetailErrorView

private final class DetailErrorView: UIView {

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

private extension UILabel {
    @discardableResult func fontMetrics() -> UILabel { self }
}
