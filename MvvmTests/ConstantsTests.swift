//
//  ConstantsTests.swift
//  MvvmTests
//
//  Created by Juan Fernandez on 28-08-26.
//

import Testing
import Foundation
@testable import Mvvm

struct ConstantsTests {

    @Test
    func movieDetailIncludesIdInPath() {
        let id = 550
        let url = Constants.Urls.movieDetail(id: id)

        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        #expect(components?.path.hasSuffix("/movie/\(id)") == true)
    }
    
    @Test
    func movieDetailIncludesApiKeyQueryParam() {
        let url = Constants.Urls.movieDetail(id: 550)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)

        let apiKeyItem = components?.queryItems?.first(where: { $0.name == "api_key" })

        #expect(apiKeyItem != nil)
        #expect(apiKeyItem?.value?.isEmpty == false)
    }
    
    @Test
    func movieDetailProducesDifferentUrlsForDifferentIds() {
        let url1 = Constants.Urls.movieDetail(id: 100)
        let url2 = Constants.Urls.movieDetail(id: 200)

        #expect(url1 != url2)
        #expect(url1.absoluteString.contains("/movie/100"))
        #expect(url2.absoluteString.contains("/movie/200"))
    }

}
