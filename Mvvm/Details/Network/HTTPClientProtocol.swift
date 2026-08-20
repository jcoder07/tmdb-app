//
//  HTTPClientProtocol.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol HTTPClientProtocol {
    func get<T: Decodable>(
        url: URL,
        as type: T.Type
    ) async throws -> T
}

