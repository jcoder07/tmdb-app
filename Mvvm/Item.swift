//
//  Item.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
