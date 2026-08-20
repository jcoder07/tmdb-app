//
//  MovieDTO.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

struct MovieDTO: Decodable {
    let originalTitle: String
    let overview: String
    let popularity: Double
}


