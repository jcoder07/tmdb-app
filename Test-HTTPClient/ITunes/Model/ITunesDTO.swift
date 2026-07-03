//
//  Test-HTTPClientDTO.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import Foundation

public struct ITunesResponseDTO: Decodable {
    public let resultCount: Int
    public let results: [ITunesResultDTO]
}

public struct ITunesResultDTO: Decodable {
    public let trackId: Int
    public let trackName: String?
    public let artistName: String?
    public let artworkUrl100: String?
}
