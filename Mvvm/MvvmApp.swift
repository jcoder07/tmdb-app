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
    
    var decoder: JSONDecoderProtocol {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
    
    var session: URLSessionProtocol {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        return session
    }
    
    var body: some Scene {
        WindowGroup {
            DetailsView(
                
                detailsViewModel: DetailsViewModel(
                    
                    repository: RemoteMovieDetailRepository(
                        httpClient: URLSessionHTTPClient(
                            session: session,
                            decoder: decoder
                        )
                    )
                )
            )
        }
    }
}

extension URLSession: URLSessionProtocol {
    
}

extension JSONDecoder: JSONDecoderProtocol {
    
}
