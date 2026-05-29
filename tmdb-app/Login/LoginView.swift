//
//  LoginView.swift
//  tmdb-app
//
//  Created by Juan Fernandez on 07-01-26.
//

import SwiftUI

struct LoginView: View {

    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        VStack(spacing: 16) {
            TextField("Usuario", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            SecureField("Contraseña", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {
                viewModel.login()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Iniciar sesión")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding(24)
        .navigationTitle("Login")
    }
}
