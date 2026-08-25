//
//  DetailsView.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI

struct DetailsView: View {
    
    @StateObject var viewModel: DetailsViewModel
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading")
                
            case .error(let errorMessage):
                Text(errorMessage)
                Button("Retry") {
                    Task {
                        await viewModel.getDetails()
                    }
                }
                
            case .loaded(let movie):
                Text(movie.originalTitle)
                Text(movie.overview)
                Text(movie.popularity, format: .number)
                
            case .idle:
                EmptyView()
            }
        }
        .padding()
        .task {
            await viewModel.getDetails()
        }
    }
}


#Preview("Details-View") {
    
    NavigationStack {
        DetailsView(viewModel: MockDetails.makeDetailsViewModel())
    }
}


