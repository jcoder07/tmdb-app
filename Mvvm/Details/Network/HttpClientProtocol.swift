//
//  HttpClient.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol HttpClientProtocol {
    
    func get(url: URL) async throws -> Data
    
}
