import UIKit
import Observation
import TMDBCore

final class LoginViewController: UIViewController {

    private let viewModel: LoginViewModel

    // MARK: - UI

    private let usernameField: UITextField = {
        let f = UITextField()
        f.placeholder = "Username"
        f.borderStyle = .roundedRect
        f.autocorrectionType = .no
        f.autocapitalizationType = .none
        f.returnKeyType = .next
        return f
    }()

    private let passwordField: UITextField = {
        let f = UITextField()
        f.placeholder = "Password"
        f.borderStyle = .roundedRect
        f.isSecureTextEntry = true
        f.returnKeyType = .go
        return f
    }()

    private let errorLabel: UILabel = {
        let l = UILabel()
        l.textColor = .systemRed
        l.font = .preferredFont(forTextStyle: .caption1)
        l.numberOfLines = 0
        l.textAlignment = .center
        l.isHidden = true
        return l
    }()

    private let loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.cornerStyle = .medium
        let b = UIButton(configuration: config)
        return b
    }()

    // MARK: - Init

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .systemBackground
        setupLayout()
        setupActions()
        startObservationLoop()
    }

    // MARK: - Layout

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [usernameField, passwordField, errorLabel, loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    // MARK: - Actions

    private func setupActions() {
        usernameField.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        usernameField.delegate = self
        passwordField.delegate = self
    }

    @objc private func usernameChanged() { viewModel.username = usernameField.text ?? "" }
    @objc private func passwordChanged() { viewModel.password = passwordField.text ?? "" }

    @objc private func loginTapped() {
        Task { await viewModel.login() }
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
        errorLabel.text = viewModel.errorMessage
        errorLabel.isHidden = viewModel.errorMessage == nil
        loginButton.isEnabled = !viewModel.isLoading
        var config = loginButton.configuration
        config?.showsActivityIndicator = viewModel.isLoading
        config?.title = viewModel.isLoading ? nil : "Login"
        loginButton.configuration = config
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            Task { await viewModel.login() }
        }
        return true
    }
}
