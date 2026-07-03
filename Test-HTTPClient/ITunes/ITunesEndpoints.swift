//
//  ITunesEndpoints.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import Foundation

public struct ITunesEndpoints {

    private static let base = "https://itunes.apple.com"

    public struct Urls {

        public static func searchTrack(term: String) -> URL {
            URL(string: "\(base)/search?term=\(term)&media=music")!
        }
    }
}
