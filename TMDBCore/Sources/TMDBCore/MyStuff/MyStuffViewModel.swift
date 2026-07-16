import Foundation
import Observation

@MainActor
@Observable
public final class MyStuffViewModel {

    public var userLists: [UserList] = []
    public var listItems: [Int: [ListItem]] = [:]
    public var isLoading = false
    public var isCreatingList = false
    public var errorMessage: String?

    private let service: any MyStuffServiceProtocol
    private let accountService: any AccountServiceProtocol
    private let sessionManager: any SessionManagerProtocol
    private var cachedAccountId: Int?

    private let nameOverrideKey = "MyStuffListNameOverrides"

    public init(service: MyStuffServiceProtocol, accountService: AccountServiceProtocol, sessionManager: SessionManagerProtocol) {
        self.service = service
        self.accountService = accountService
        self.sessionManager = sessionManager
    }

    // MARK: - Load

    public func load() async {
        guard !isLoading else { return }
        guard let sessionId = sessionManager.getSession() else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let accountId = try await resolvedAccountId(sessionId: sessionId)
            userLists = try await service.fetchUserLists(accountId: accountId, sessionId: sessionId)
        } catch {
            if Task.isCancelled { return }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - List items

    public func fetchListItems(listId: Int) async {
        guard listItems[listId] == nil else { return }
        do {
            listItems[listId] = try await service.fetchListItems(listId: listId)
        } catch {
            listItems[listId] = []
        }
    }

    // MARK: - Create list

    public func createList(name: String) async {
        guard let sessionId = sessionManager.getSession(), !isCreatingList else { return }
        isCreatingList = true
        do {
            let newList = try await service.createList(name: name, sessionId: sessionId)
            userLists.append(newList)
            listItems[newList.id] = []
        } catch { }
        isCreatingList = false
    }

    // MARK: - Delete list

    public func deleteList(listId: Int) async {
        guard let sessionId = sessionManager.getSession() else { return }
        userLists.removeAll(where: { $0.id == listId })
        listItems.removeValue(forKey: listId)
        removeLocalName(for: listId)
        do {
            try await service.deleteList(listId: listId, sessionId: sessionId)
        } catch {
            await load()
        }
    }

    // MARK: - Remove item from list

    public func removeFromList(listId: Int, mediaId: Int) async {
        guard let sessionId = sessionManager.getSession() else { return }
        listItems[listId]?.removeAll(where: { $0.id == mediaId })
        do {
            try await service.removeFromList(listId: listId, mediaId: mediaId, sessionId: sessionId)
        } catch {
            listItems.removeValue(forKey: listId)
            await fetchListItems(listId: listId)
        }
    }

    // MARK: - Local name overrides (UserDefaults)

    public func displayName(for list: UserList) -> String {
        localName(for: list.id) ?? list.name
    }

    public func localName(for listId: Int) -> String? {
        let overrides = UserDefaults.standard.dictionary(forKey: nameOverrideKey) as? [String: String]
        return overrides?["\(listId)"]
    }

    public func setLocalName(_ name: String, for listId: Int) {
        var overrides = (UserDefaults.standard.dictionary(forKey: nameOverrideKey) as? [String: String]) ?? [:]
        overrides["\(listId)"] = name.trimmingCharacters(in: .whitespaces)
        UserDefaults.standard.set(overrides, forKey: nameOverrideKey)
    }

    // MARK: - Private helpers

    private func resolvedAccountId(sessionId: String) async throws -> Int {
        if let cached = cachedAccountId { return cached }
        let profile = try await accountService.fetchAccountDetails(sessionId: sessionId)
        cachedAccountId = profile.id
        return profile.id
    }

    private func removeLocalName(for listId: Int) {
        var overrides = (UserDefaults.standard.dictionary(forKey: nameOverrideKey) as? [String: String]) ?? [:]
        overrides.removeValue(forKey: "\(listId)")
        UserDefaults.standard.set(overrides, forKey: nameOverrideKey)
    }
}
