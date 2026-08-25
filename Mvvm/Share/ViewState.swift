//
//  ViewState.swift
//  Mvvm
//
//  Created by Juan Fernandez on 25-08-26.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

