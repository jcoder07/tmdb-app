import UIKit
import TMDBCore

final class MediaItemCell: UITableViewCell {

    static let reuseID = "MediaItemCell"

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

final class MediaErrorView: UIView {

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
