//
//  DetailsViewModel.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI
import Combine

class DetailsViewModel: ObservableObject {
    
    @Published var numberOne: String = ""
    @Published var numberTwo: String = ""
    @Published var result: Int = 0
    
    func sum() {
        let firstNumber = Int(numberOne) ?? 0
        let secondNumber = Int(numberTwo) ?? 0
        
        result = firstNumber + secondNumber
    }
}
