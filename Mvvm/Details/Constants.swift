//
//  Constants.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation


public struct Constants {

    private static let base = TMDBConfig.baseURL
    private static let key = TMDBConfig.apiKey

    public struct Urls {
        public static func movieDetail(id: Int) -> URL {
            URL(string: "\(base)/movie/\(id)?api_key=\(key)")!
        }
    }
}


