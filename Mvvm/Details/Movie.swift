//
//  MoviesDTO.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import Foundation

struct Movie: Decodable {
    let originalTitle: String
    let overview: String
    let popularity: Double
}

