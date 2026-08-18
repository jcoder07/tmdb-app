//
//  DetailsView.swift
//  Mvvm
//
//  Created by Juan Fernandez on 18-08-26.
//

import SwiftUI

struct DetailsView: View {
    
    @StateObject var detailsViewModel: DetailsViewModel
    
    var body: some View {
        VStack {
            TextField("Primer Numero", text: $detailsViewModel.numberOne)
                .textFieldStyle(.roundedBorder)
                .frame(height: 40)
            
            TextField("Segundo Numero", text: $detailsViewModel.numberTwo)
                .textFieldStyle(.roundedBorder)
                .frame(height: 40)
            
            Button("Sumar") {
                detailsViewModel.sum()
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
    
            
            if detailsViewModel.result > 0 {
                Text("El resultado es: \(detailsViewModel.result, specifier: "%ld")")
                    .font(.title2)
                    .bold()
            }

        }
        .padding()
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


