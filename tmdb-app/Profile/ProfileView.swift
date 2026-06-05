//
//  ProfileView.swift
//  tmdb-app
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Text("Profile")
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                        }
                    }
                }
        }
    }
}
