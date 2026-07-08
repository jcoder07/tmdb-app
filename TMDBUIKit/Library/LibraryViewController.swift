import UIKit
import TMDBCore

final class LibraryViewController: UIViewController {

    private let watchlistVC: WatchlistViewController
    private let favoritesVC: FavoritesViewController

    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Watchlist", "Favorites"])
        control.selectedSegmentIndex = 0
        return control
    }()

    private var activeChild: UIViewController?

    // MARK: - Init

    init(watchlistViewModel: WatchlistViewModel, favoritesViewModel: FavoritesViewModel) {
        self.watchlistVC = WatchlistViewController(viewModel: watchlistViewModel)
        self.favoritesVC = FavoritesViewController(viewModel: favoritesViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Watchlist"
        view.backgroundColor = .systemBackground
        setupLayout()
        showChild(watchlistVC)
    }

    // MARK: - Layout

    private func setupLayout() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }

    @objc private func segmentChanged() {
        let selected = segmentedControl.selectedSegmentIndex == 0 ? watchlistVC : favoritesVC
        title = segmentedControl.selectedSegmentIndex == 0 ? "Watchlist" : "Favorites"
        showChild(selected)
    }

    // MARK: - Child VC containment

    private func showChild(_ child: UIViewController) {
        guard child !== activeChild else { return }

        if let current = activeChild {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }

        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        child.didMove(toParent: self)
        activeChild = child
    }
}
