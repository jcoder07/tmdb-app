//
//  DetailsViewModel.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI
import Combine

@MainActor
class DetailsViewModel: ObservableObject {
    
    @Published var movie: Movie?
    
    public func getDetails() async {
        let url = Constants.Urls.movieDetail(id: 18)
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            movie = try decoder.decode(Movie.self, from: data)
            
        } catch {
            print(error)
        }
    }
}
