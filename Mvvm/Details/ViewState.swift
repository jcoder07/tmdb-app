//
//  ViewState.swift
//  Mvvm
//
//  Created by Juan Fernandez on 25-08-26.
//

import Foundation

enum ViewState {
    case idle
    case loading
    case loaded(Movie)
    case error(String)
}

