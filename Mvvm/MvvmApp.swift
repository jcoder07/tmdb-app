//
//  MvvmApp.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI
import SwiftData

@main
struct MvvmApp: App {
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    
    var body: some Scene {
        WindowGroup {
            DetailsView(
                
                detailsViewModel: DetailsViewModel(
                    
                    repository: RemoteMovieDetailRepository(httpClient: URLSessionHTTPClient(session: .shared, decoder: decoder))
                )
                
            )
        }
    }
}
