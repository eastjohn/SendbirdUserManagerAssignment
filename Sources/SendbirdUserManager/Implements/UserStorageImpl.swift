//
//  UserStorageImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class UserStorageImpl: SBUserStorage {
    func upsertUser(_ user: SBUser) {
    }

    func getUsers() -> [SBUser] {
        []
    }

    func getUsers(for nickname: String) -> [SBUser] {
        []
    }

    func getUser(for userId: String) -> (SBUser)? {
        nil
    }
}

private protocol Cache {
    associatedtype D
    func get(_ key: String) -> D?
    func getAll() -> [SBUser]
    func set(_ key: String, data: D)
    func clear()
}

private final class MemoryCache: Cache {
    var storage: [String: SBUser] = [:]

    func get(_ key: String) -> SBUser? {
        storage[key]
    }

    func getAll() -> [SBUser] {
        storage.map { $0.value }
    }

    func set(_ key: String, data: SBUser) {
        storage[key] = data
    }

    func clear() {
        storage = [:]
    }
}
