//
//  ProfileView.swift
//  tmdb-app
//

import SwiftUI
import Charts

// MARK: - Models

struct UserProfile {
    let username: String
    let avatarPath: String?
    let memberSince: String
    let avgMovieScore: Double
    let avgTVScore: Double
    let totalEdits: Int
    let totalRatings: Int
    let ratingDistribution: [RatingBar]
    let topGenres: [GenreSlice]
}

struct RatingBar: Identifiable {
    let id = UUID()
    let rating: Int
    let count: Int
}

struct GenreSlice: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let percentage: Double
}

// MARK: - Preview Data

extension UserProfile {
    static let preview = UserProfile(
        username: "Juanjo07",
        avatarPath: nil,
        memberSince: "June 2023",
        avgMovieScore: 40,
        avgTVScore: 0,
        totalEdits: 0,
        totalRatings: 1,
        ratingDistribution: [
            RatingBar(rating: 1, count: 0),
            RatingBar(rating: 2, count: 0),
            RatingBar(rating: 3, count: 0),
            RatingBar(rating: 4, count: 1),
            RatingBar(rating: 5, count: 0),
            RatingBar(rating: 6, count: 0),
            RatingBar(rating: 7, count: 0),
            RatingBar(rating: 8, count: 0),
            RatingBar(rating: 9, count: 0),
            RatingBar(rating: 10, count: 0),
        ],
        topGenres: [
            GenreSlice(name: "Action", color: Color(hex: "E8820C"), percentage: 0.50),
            GenreSlice(name: "Drama", color: Color(hex: "C9873B"), percentage: 0.30),
            GenreSlice(name: "Adventure", color: Color(hex: "E8C49A"), percentage: 0.20),
        ]
    )
}

// MARK: - ProfileView

struct ProfileView: View {

    let profile: UserProfile = .preview
    @State private var showLogoutAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                contentSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .alert("Cerrar sesión", isPresented: $showLogoutAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Cerrar sesión", role: .destructive) {
                // TODO: conectar con AuthViewModel
            }
        } message: {
            Text("¿Estás seguro de que quieres cerrar sesión?")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            // Fondo degradado azul oscuro como TMDB
            LinearGradient(
                colors: [Color(hex: "0D253F"), Color(hex: "1A3A5C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(maxWidth: .infinity)

            // Decoración diagonal (líneas naranjas como TMDB)
            diagonalDecorations

            // Contenido del header
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 20) {
                    avatarView

                    VStack(alignment: .leading, spacing: 6) {
                        Text(profile.username)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("Member since \(profile.memberSince)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))

                        HStack(spacing: 20) {
                            scoreCircle(
                                value: profile.avgMovieScore,
                                label: "Average\nMovie Score"
                            )
                            Divider()
                                .frame(height: 44)
                                .overlay(Color.white.opacity(0.3))
                            scoreCircle(
                                value: profile.avgTVScore,
                                label: "Average\nTV Score"
                            )
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 28)
            }
        }
    }

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "0668E1"))
                .frame(width: 80, height: 80)

            // Icono por defecto estilo TMDB (power icon)
            Image(systemName: "person.fill")
                .font(.system(size: 34))
                .foregroundStyle(.white)
        }
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
        )
    }

    private func scoreCircle(value: Double, label: String) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(
                        value > 0 ? Color(hex: "D4AF37") : Color.gray,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))

                Text("\(Int(value))%")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // Líneas diagonales decorativas estilo TMDB
    private var diagonalDecorations: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "E8820C").opacity(0.7))
                .frame(width: 6, height: 60)
                .rotationEffect(.degrees(-45))
                .offset(x: -40, y: 20)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "E8820C").opacity(0.5))
                .frame(width: 6, height: 40)
                .rotationEffect(.degrees(-45))
                .offset(x: -70, y: 10)

            RoundedRectangle(cornerRadius: 3)
                .fill(Color(hex: "C9873B").opacity(0.6))
                .frame(width: 6, height: 50)
                .rotationEffect(.degrees(-45))
                .offset(x: -15, y: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .clipped()
    }

    // MARK: - Content / Stats

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Título Stats
            Text("Stats")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 4)

            // Grid: Total Edits + Total Ratings
            HStack(spacing: 16) {
                statCard(title: "Total Edits", value: "\(profile.totalEdits)")
                statCard(title: "Total Ratings", value: "\(profile.totalRatings)")
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            // Rating Overview (gráfico de barras)
            ratingOverviewCard
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // Most Watched Genres (donut)
            genresCard
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // Botón Logout
            logoutButton
                .padding(.horizontal, 16)
                .padding(.top, 28)
                .padding(.bottom, 40)
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Color(hex: "E8820C"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var ratingOverviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating Overview")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Chart(profile.ratingDistribution) { bar in
                BarMark(
                    x: .value("Rating", bar.rating),
                    y: .value("Count", bar.count)
                )
                .foregroundStyle(Color(hex: "E8820C"))
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: Array(1...10)) { value in
                    AxisValueLabel {
                        Text("\(value.index + 1)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 100)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var genresCard: some View {
        HStack(spacing: 20) {
            // Donut chart manual
            ZStack {
                ForEach(Array(donutSegments().enumerated()), id: \.offset) { _, segment in
                    Circle()
                        .trim(from: segment.start, to: segment.end)
                        .stroke(segment.color, style: StrokeStyle(lineWidth: 20, lineCap: .butt))
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                }
                Circle()
                    .fill(Color(.systemBackground))
                    .frame(width: 44, height: 44)
            }

            // Leyenda
            VStack(alignment: .leading, spacing: 8) {
                Text("Most Watched Genres")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(profile.topGenres) { genre in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(genre.color)
                            .frame(width: 14, height: 14)
                        Text(genre.name)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func donutSegments() -> [(start: Double, end: Double, color: Color)] {
        var result: [(start: Double, end: Double, color: Color)] = []
        var current = 0.0
        for genre in profile.topGenres {
            let end = current + genre.percentage
            result.append((start: current, end: end, color: genre.color))
            current = end
        }
        return result
    }

    private var logoutButton: some View {
        Button {
            showLogoutAlert = true
        } label: {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Cerrar sesión")
                    .fontWeight(.medium)
                Spacer()
            }
            .foregroundStyle(.red)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview {
    ProfileView()
}
