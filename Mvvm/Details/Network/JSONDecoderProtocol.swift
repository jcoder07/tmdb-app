//
//  JSONDecoderProtocol.swift
//  Mvvm
//
//  Created by Juan Fernandez on 20-08-26.
//

import Foundation

protocol JSONDecoderProtocol {
    
    func decode<T>(
        _ type: T.Type,
        from data: Data
    ) throws -> T where T : Decodable
    
}
