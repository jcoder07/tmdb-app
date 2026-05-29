//
//  LoginView.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import SwiftUI

struct LoginView: View {

    let sessionManager: SessionManagerProtocol
    let onLoginSuccess: () -> Void

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 16) {
            TextField("Usuario", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            SecureField("Contraseña", text: $password)
                .textFieldStyle(.roundedBorder)

            if let error = errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                login()
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Iniciar sesión")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding(24)
        .navigationTitle("Login")
    }

    private func login() {
        isLoading = true
        errorMessage = nil

        let authService = TMDBAuthService()

        authService.createRequestToken { result in
            switch result {
            case .success(let tokenResponse):
                guard let token = tokenResponse.requestToken else {
                    DispatchQueue.main.async { isLoading = false }
                    return
                }
                authService.validateLogin(
                    username: username,
                    password: password,
                    requestToken: token
                ) { result in
                    switch result {
                    case .success:
                        authService.createSession(requestToken: token) { result in
                            DispatchQueue.main.async {
                                isLoading = false
                                switch result {
                                case .success(let sessionResponse):
                                    sessionManager.saveSession(id: sessionResponse.sessionId)
                                    onLoginSuccess()
                                case .failure(let error):
                                    errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            isLoading = false
                            errorMessage = error.localizedDescription
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
