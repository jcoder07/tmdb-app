import Foundation
import Testing
import TMDBCore
@testable import TMDBSwiftUI

extension TMDBSwiftUIIntegrationTests {

@Suite
struct LoginFlowIntegrationTests {

    @Test func loginHappyPathDrivesTheRealThreeStepAuthFlow() async throws {
        let stack = IntegrationStack()
        stack.stub(path: "/authentication/token/new", json: Fixtures.requestToken)
        stack.stub(path: "/authentication/token/validate_with_login", json: Fixtures.validateLoginOK)
        stack.stub(path: "/authentication/session/new", json: Fixtures.createSession)

        let viewModel = await MainActor.run {
            let vm = stack.makeLoginViewModel()
            vm.username = "fixture-user"
            vm.password = "fixture-password"
            return vm
        }
        await viewModel.login()

        let requests = stack.recordedRequests
        #expect(requests.count == 3)
        #expect(requests[0].url.path.hasSuffix("/authentication/token/new"))
        #expect(requests[1].url.path.hasSuffix("/authentication/token/validate_with_login"))
        #expect(requests[1].method == "POST")
        #expect(requests[2].url.path.hasSuffix("/authentication/session/new"))
        #expect(requests[2].method == "POST")

        // Resource(url:body:modelType:) encodes with .convertToSnakeCase.
        let validateBody = try #require(requests[1].body)
        let validateJSON = try #require(try JSONSerialization.jsonObject(with: validateBody) as? [String: Any])
        #expect(validateJSON["request_token"] as? String == "fixture-request-token")
        #expect(validateJSON["username"] as? String == "fixture-user")
        #expect(validateJSON["password"] as? String == "fixture-password")

        let sessionBody = try #require(requests[2].body)
        let sessionJSON = try #require(try JSONSerialization.jsonObject(with: sessionBody) as? [String: Any])
        #expect(sessionJSON["request_token"] as? String == "fixture-request-token")

        #expect(stack.sessionManager.getSession() == "fixture-session-id")
        #expect(await viewModel.errorMessage == nil)
    }

    @Test func loginStopsWhenTokenResponseHasNoRequestToken() async throws {
        let stack = IntegrationStack()
        stack.stub(path: "/authentication/token/new", json: Fixtures.requestTokenMissing)

        let viewModel = await stack.makeLoginViewModel()
        await viewModel.login()

        #expect(stack.recordedRequests.count == 1)
        #expect(stack.sessionManager.getSession() == nil)
        #expect(await viewModel.errorMessage == nil)
    }

    @Test func loginSurfacesTheRealDecodingErrorForATMDBErrorPayload() async throws {
        // HttpClient ignores HTTP status codes and only checks that a response exists. A TMDB
        // error payload still decodes cleanly into RequestTokenResponse (its non-"success"
        // fields are optional), so the real failure only surfaces at createSession, whose
        // response requires a non-optional `session_id` the error payload doesn't have.
        let stack = IntegrationStack()
        stack.stub(path: "/authentication/token/new", json: Fixtures.requestToken)
        stack.stub(path: "/authentication/token/validate_with_login", json: Fixtures.validateLoginOK)
        stack.stub(path: "/authentication/session/new", statusCode: 401, json: Fixtures.tmdbAuthError)

        let viewModel = await stack.makeLoginViewModel()
        await viewModel.login()

        #expect(await viewModel.errorMessage == NetworkError.decodingError.localizedDescription)
        #expect(stack.sessionManager.getSession() == nil)
    }
}

}
