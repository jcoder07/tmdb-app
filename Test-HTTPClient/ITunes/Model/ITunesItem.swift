//
//  ITunesItem.swift
//  Test-HTTPClient
//
//  Created by Juan Fernandez on 01-07-26.
//

import Foundation

public struct ITunesTrack: Identifiable, Sendable {
    public let trackId: Int
    public let trackName: String?
    public let artistName: String?
    public let artworkUrl100: String?
    public var id: Int { trackId }
    
    
    public var artworkURL: URL? {
            guard let artworkUrl100 else { return nil }
            return URL(string: artworkUrl100)
        }
}


extension ITunesTrack {
    public init(_ track: ITunesResultDTO) {
        self.init(
            trackId: track.trackId,
            trackName: track.trackName,
            artistName: track.artistName,
            artworkUrl100: track.artworkUrl100
        )
    }
}
