import UIKit
import TMDBCore

final class HomeViewController: UIViewController {

    private let viewModel: HomeViewModel
    private let profileViewModel: ProfileViewModel
    private let onGoToWatchlist: () -> Void

    init(viewModel: HomeViewModel, profileViewModel: ProfileViewModel, onGoToWatchlist: @escaping () -> Void) {
        self.viewModel = viewModel
        self.profileViewModel = profileViewModel
        self.onGoToWatchlist = onGoToWatchlist
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = .systemBackground
        setupLayout()
        setupNavBar()
    }

    // MARK: - Layout

    private func setupLayout() {
        let label = UILabel()
        label.text = "🎬 Welcome to TMDB"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
    }

    // MARK: - Actions

    @objc private func profileTapped() {
        let profileVC = ProfileViewController(
            viewModel: profileViewModel,
            onGoToWatchlist: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onGoToWatchlist()
                }
            }
        )
        let nav = UINavigationController(rootViewController: profileVC)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }
}
