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
        // Arrange
        let sut: DetailsViewModel = makeSUT()
        
        // Act
        sut.numberOne = "10"
        sut.numberTwo = "20"
        sut.sum()
        
        // Assert
        #expect(sut.result == 30)
    }
    
    @Test func testSumWithInitialValueZero() {
        // Arrange
        let sut: DetailsViewModel = makeSUT()
        
        // Act
        sut.numberOne = "t"
        sut.numberTwo = "j"
        sut.sum()
        
        // Assert
        #expect(sut.result == 0)
    }
    
    @Test func testFormattedResult() {
        // Arrange
        let sut: DetailsViewModel = makeSUT()
        
        // Act
        sut.numberOne = "7"
        sut.numberTwo = "7"
        sut.sum()
        
        // Assert
        #expect(sut.formattedResult == "14")
    }
    
    
    func makeSUT() -> DetailsViewModel {
        return DetailsViewModel()
    }

}
