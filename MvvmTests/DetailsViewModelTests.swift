//
//  DetailsViewModelTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 18-08-26.
//

import Testing
@testable import Mvvm

struct DetailsViewModelTests {

    @Test func testSum() {
        let sut: DetailsViewModel = makeSUT()
        
        sut.numberOne = "10"
        sut.numberTwo = "20"
        
        sut.sum()
        
        #expect(sut.result == 30)
    }
    
    @Test func testSumWithInitialValueZero() {
        let sut: DetailsViewModel = makeSUT()
        
        sut.numberOne = "t"
        sut.numberTwo = "j"
        
        sut.sum()
        
        #expect(sut.result == 0)
    }
    
    @Test func testFormattedResult() {
        let sut: DetailsViewModel = makeSUT()
        
        sut.numberOne = "7"
        sut.numberTwo = "7"
        
        sut.sum()
        
        #expect(sut.formattedResult == "14")
    }
    
    
    func makeSUT() -> DetailsViewModel {
        return DetailsViewModel()
    }

}
