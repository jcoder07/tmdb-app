//
//  TMDBSwiftUIIntegrationTests.swift
//  TMDBSwiftUIIntegrationTests
//
//  Created by Juan Fernandez on 17-08-26.
//

import Testing
import TMDBCore

/// Sanity check for the harness itself: this bundle is hosted by TMDBSwiftUI, so `Bundle.main`
/// must resolve to the app and `TMDBConfig` must read its Info.plist-injected values.
///
/// `.serialized` here is load-bearing beyond this suite's own tests: `StubURLProtocol`'s route
/// table is process-global static state, and this trait recursively serializes every nested
/// suite declared under `TMDBSwiftUIIntegrationTests` in the other files in this target.
/// Without it, Swift Testing's default parallelism lets unrelated flows race on that state.
@Suite(.serialized)
struct TMDBSwiftUIIntegrationTests {

    @Test func testHostConfigResolvesFromTheAppBundle() {
        #expect(!TMDBConfig.baseURL.isEmpty)
    }
}
