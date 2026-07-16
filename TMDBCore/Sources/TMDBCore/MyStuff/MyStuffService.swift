import Foundation

public protocol MyStuffServiceProtocol: Sendable {
    func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList]
    func fetchListItems(listId: Int) async throws -> [ListItem]
    func createList(name: String, sessionId: String) async throws -> UserList
    func deleteList(listId: Int, sessionId: String) async throws
    func removeFromList(listId: Int, mediaId: Int, sessionId: String) async throws
}

public final class MyStuffService: MyStuffServiceProtocol {

    private let httpClient: HttpClientProtocol

    public init(httpClient: HttpClientProtocol) {
        self.httpClient = httpClient
    }

    public func fetchUserLists(accountId: Int, sessionId: String) async throws -> [UserList] {
        let resource = Resource(url: Constants.Urls.accountLists(accountId: accountId, sessionId: sessionId), modelType: UserListsResponseDTO.self)
        return try await httpClient.load(resource).results.map(UserList.init)
    }

    public func fetchListItems(listId: Int) async throws -> [ListItem] {
        let resource = Resource(url: Constants.Urls.listItems(listId: listId), modelType: ListDetailDTO.self)
        let detail = try await httpClient.load(resource)
        return detail.items.map(ListItem.init)
    }

    public func createList(name: String, sessionId: String) async throws -> UserList {
        let body = CreateListRequest(name: name, description: "", language: "en")
        let resource = try Resource(url: Constants.Urls.createList(sessionId: sessionId), body: body, modelType: CreateListResponseDTO.self)
        let response = try await httpClient.load(resource)
        guard let listId = response.listId else { throw NetworkError.decodingError }
        return UserList(id: listId, name: name, description: "", itemCount: 0)
    }

    public func deleteList(listId: Int, sessionId: String) async throws {
        let resource = Resource(
            url: Constants.Urls.deleteList(listId: listId, sessionId: sessionId),
            method: .delete,
            modelType: TMDBStatusResponse.self
        )
        _ = try await httpClient.load(resource)
    }

    public func removeFromList(listId: Int, mediaId: Int, sessionId: String) async throws {
        let body = RemoveFromListRequest(mediaId: mediaId)
        let resource = try Resource(url: Constants.Urls.removeFromList(listId: listId, sessionId: sessionId), body: body, modelType: TMDBStatusResponse.self)
        _ = try await httpClient.load(resource)
    }
}
