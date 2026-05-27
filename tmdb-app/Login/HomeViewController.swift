//
//  HomeViewController.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import UIKit

final class HomeViewController: UIViewController {

    // MARK: - Dependencies

    private let sessionManager: SessionManagerProtocol

    init(sessionManager: SessionManagerProtocol) {
        self.sessionManager = sessionManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Elements

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cerrar sesión", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "🎬 Bienvenido a TMDB"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Home"

        setupUI()
        setupActions()
    }

    // MARK: - Setup

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(logoutButton)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoutButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        ])
    }

    private func setupActions() {
        logoutButton.addTarget(
            self,
            action: #selector(logoutTapped),
            for: .touchUpInside
        )
    }

    // MARK: - Actions

    @objc private func logoutTapped() {
        sessionManager.clearSession()

        let loginVC = LoginViewController(sessionManager: sessionManager)
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    deinit {
        print("HomeViewController deinit")
    }
}
