import UIKit

final class SeriesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Series"
        view.backgroundColor = .systemBackground
        let label = UILabel()
        label.text = "Series"
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
