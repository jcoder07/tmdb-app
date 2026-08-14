import Testing
@testable import TMDBCore

// Uses DummySessionManager, FakeSessionManager, StubAuthService, SpyAuthService from TestDoubles.swift

@MainActor
struct LoginViewModelTests {

    private func makeSUT(
        sessionManager: any SessionManagerProtocol = DummySessionManager(),
        authService: any TMDBAuthServiceProtocol = StubAuthService(),
        onLoginSuccess: @escaping () -> Void = {}
    ) -> LoginViewModel {
        LoginViewModel(sessionManager: sessionManager, authService: authService, onLoginSuccess: onLoginSuccess)
    }

    // MARK: - Successful login

    @Test func successfulLoginCallsThreeStepAuthFlow_usingSpyAuthService() async {
        let spy = SpyAuthService()
        spy.tokenToReturn = RequestTokenResponse(success: true, expiresAt: nil, requestToken: "tok-123")
        let sut = makeSUT(authService: spy)
        sut.username = "alice"
        sut.password = "p@ss"

        await sut.login()

        // 1. createRequestToken
        #expect(spy.createTokenCallCount == 1)
        // 2. validateLogin with correct args and the received token
        #expect(spy.validateLoginCalls.count == 1)
        #expect(spy.validateLoginCalls[0].username == "alice")
        #expect(spy.validateLoginCalls[0].password == "p@ss")
        #expect(spy.validateLoginCalls[0].token == "tok-123")
        // 3. createSession with the same token
        #expect(spy.createSessionCalls == ["tok-123"])
    }

    @Test func successfulLoginSavesSessionId_usingFakeSessionManager() async {
        let spy = SpyAuthService()
        spy.sessionToReturn = CreateSessionResponse(success: true, sessionId: "my-session-id")
        let fakeSession = FakeSessionManager()
        let sut = makeSUT(sessionManager: fakeSession, authService: spy)

        await sut.login()

        #expect(fakeSession.getSession() == "my-session-id")
        #expect(fakeSession.isLoggedIn == true)
    }

    @Test func successfulLoginCallsOnLoginSuccessCallback() async {
        var called = false
        let sut = makeSUT(onLoginSuccess: { called = true })

        await sut.login()

        #expect(called == true)
    }

    @Test func loginSetsIsLoadingFalseAfterSuccess() async {
        let sut = makeSUT()
        await sut.login()
        #expect(sut.isLoading == false)
    }

    @Test func loginClearsErrorMessageOnStart() async {
        let stub = StubAuthService()
        let sut = makeSUT(authService: stub)
        // Inject a stale error
        sut.errorMessage = "Previous error"

        await sut.login()

        #expect(sut.errorMessage == nil)
    }

    // MARK: - Failed login – using DummySessionManager to show it's never touched

    @Test func tokenFailureSetErrorMessageAndDoesNotSaveSession_usingDummy() async {
        let stub = StubAuthService()
        stub.errorToThrow = NetworkError.serverError("Invalid API key.")
        let dummy = DummySessionManager()  // Dummy: never called, irrelevant to this path
        var callbackCalled = false
        let sut = makeSUT(sessionManager: dummy, authService: stub, onLoginSuccess: { callbackCalled = true })

        await sut.login()

        #expect(sut.errorMessage != nil)
        #expect(callbackCalled == false)
        #expect(sut.isLoading == false)
    }

    @Test func validateFailureSetsErrorAndDoesNotCallOnSuccess_usingSpyAuthService() async {
        let spy = SpyAuthService()
        spy.validateErrorToThrow = NetworkError.serverError("Invalid credentials.")
        var callbackCalled = false
        let sut = makeSUT(authService: spy, onLoginSuccess: { callbackCalled = true })
        sut.username = "user"
        sut.password = "wrong"

        await sut.login()

        #expect(callbackCalled == false)
        #expect(sut.errorMessage != nil)
        #expect(spy.createSessionCalls.isEmpty)  // createSession was never reached
    }

    @Test func validateFailureDoesNotSaveSession_usingFakeSessionManager() async {
        let spy = SpyAuthService()
        spy.validateErrorToThrow = NetworkError.invalidResponse
        let fakeSession = FakeSessionManager()
        let sut = makeSUT(sessionManager: fakeSession, authService: spy)

        await sut.login()

        #expect(fakeSession.isLoggedIn == false)
    }

    @Test func nilTokenReturnsEarlyWithoutCallingValidateOrOnSuccess_usingSpyAuthService() async {
        let spy = SpyAuthService()
        spy.tokenToReturn = RequestTokenResponse(success: false, expiresAt: nil, requestToken: nil)
        var callbackCalled = false
        let sut = makeSUT(authService: spy, onLoginSuccess: { callbackCalled = true })

        await sut.login()

        #expect(callbackCalled == false)
        #expect(spy.validateLoginCalls.isEmpty)
        #expect(spy.createSessionCalls.isEmpty)
    }
}
