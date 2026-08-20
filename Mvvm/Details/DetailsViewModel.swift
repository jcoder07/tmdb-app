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
    
    public func getDetails() {
        let url = Constants.Urls.movieDetail(id: 18)
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let error {
                print(error)
                return
            }
            
            guard let data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                
                let movie = try decoder.decode(
                    Movie.self,
                    from: data
                )
                
                DispatchQueue.main.async {
                    self?.movie = movie
                }
                
            } catch {
                print(error)
            }
            
        }.resume()
        
        
    }
}
