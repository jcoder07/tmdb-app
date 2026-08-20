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
    
    var body: some Scene {
        WindowGroup {
            DetailsView(
                
                detailsViewModel: DetailsViewModel(
                    
                    repository: RemoteUserRepository(httpClient: URLSessionHTTPClient())
                    
                )
                
            )
        }
    }
}
