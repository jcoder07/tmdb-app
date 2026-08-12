//
//  LoginView.swift
//  tmdb-app
//

import SwiftUI
import TMDBCore

struct LoginView: View {

    @Bindable var viewModel: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("appColorScheme") private var storedScheme: Int = 0
    @State private var showPassword = false

    private var bg: Color {
        colorScheme == .dark ? Color(hex: "1A1A18") : Color(hex: "F2EDE0")
    }
    private var fieldBg: Color {
        colorScheme == .dark ? Color(hex: "2C2C2A") : .white
    }
    private let accent = Color(hex: "C5A55A")
    private var buttonBg: Color {
        colorScheme == .dark ? Color(hex: "8B6B1F") : Color(hex: "D9C09A")
    }
    private var buttonFg: Color {
        colorScheme == .dark ? .white : Color(hex: "3D2E10")
    }
    private var primaryText: Color {
        colorScheme == .dark ? .white : Color(hex: "1A1A1A")
    }
    private var secondaryText: Color {
        colorScheme == .dark ? Color(hex: "888888") : Color(hex: "999999")
    }
    private var fieldBorder: Color { Color(hex: "E0D5C0") }

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + title
                VStack(spacing: 10) {
                    Image(systemName: "film")
                        .font(.system(size: 52))
                        .foregroundStyle(accent)

                    Text("Login")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(primaryText)

                    Text("Powered by TMDB")
                        .font(.system(size: 12))
                        .foregroundStyle(secondaryText)
                        .tracking(0.4)
                }

                Spacer().frame(height: 48)

                // Fields
                VStack(spacing: 14) {
                    // Username
                    HStack(spacing: 12) {
                        Image(systemName: "person")
                            .foregroundStyle(accent)
                            .frame(width: 20)
                        TextField("Username", text: $viewModel.username)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(fieldBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        if colorScheme == .light {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(fieldBorder, lineWidth: 1)
                        }
                    }

                    // Password
                    HStack(spacing: 12) {
                        Image(systemName: "lock")
                            .foregroundStyle(accent)
                            .frame(width: 20)
                        Group {
                            if showPassword {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                        }
                        .foregroundStyle(primaryText)
                        Button {
                            showPassword.toggle()
                        } label: {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundStyle(accent)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(fieldBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        if colorScheme == .light {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(fieldBorder, lineWidth: 1)
                        }
                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 24)

                // Login button
                Button {
                    Task { await viewModel.login() }
                } label: {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView().tint(buttonFg)
                        } else {
                            Text("Login")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(buttonFg)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(buttonBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal, 32)
                .disabled(viewModel.isLoading)

                Spacer().frame(height: 20)

                Text("By logging in you accept TMDB's terms")
                    .font(.caption2)
                    .foregroundStyle(secondaryText)

                Spacer()
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                storedScheme = colorScheme == .dark ? 1 : 2
            } label: {
                Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(accent)
                    .frame(width: 40, height: 40)
                    .background(fieldBg)
                    .clipShape(Circle())
                    .overlay {
                        if colorScheme == .light {
                            Circle().stroke(fieldBorder, lineWidth: 1)
                        }
                    }
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}
