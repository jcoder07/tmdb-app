//
//  DetailsView.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI

struct DetailsView: View {
    
    let detailsViewModel: DetailsViewModel
    
    @State var numberOne: String = ""
    @State var numberTwo: String = ""
    @State var result: Int = 0
    
    var body: some View {
        VStack {
            TextField("Primer Numero", text: $numberOne)
                .textFieldStyle(.roundedBorder)
                .frame(height: 40)
            
            TextField("Segundo Numero", text: $numberTwo)
                .textFieldStyle(.roundedBorder)
                .frame(height: 40)
            
            Button("Sumar") {
               sumar()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
    
            
            if result > 0 {
                Text("El resultado es: \(result, specifier: "%ld")")
                    .font(.title2)
                    .bold()
            }

        }
        .padding()
    }
    
    func sumar() {
        let firstNumber = Int(numberOne) ?? 0
        let secondNumber = Int(numberTwo) ?? 0
        
        result = firstNumber + secondNumber
    }
    
    
}


#Preview("Details-View") {
    NavigationStack {
        let detailsViewModel = DetailsViewModel() // Here I create the object.
        
        DetailsView(
            detailsViewModel: detailsViewModel // Here i pass the object as a parameter.
        )
    }
}


