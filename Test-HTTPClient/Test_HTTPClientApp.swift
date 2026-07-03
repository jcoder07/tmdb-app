//
//  Test_HTTPClientApp.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import SwiftUI
import TMDBCore

@main
struct Test_HTTPClientApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ITunesView(viewModel: ITunesViewModel(
                    service: ITunesService(httpClient: HttpClient())
                ))
            }
        }
    }
}
