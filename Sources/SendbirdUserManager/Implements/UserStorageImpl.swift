//
//  UserStorageImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class UserStorageImpl: SBUserStorage {
    private let queue: DispatchQueue = .init(label: "com.userStorageQueue.concurrency", attributes: .concurrent)
    private let cache = MemoryCache()
    
    func upsertUser(_ user: SBUser) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache.set(user.userId, data: user)
        }
    }

    func getUsers() -> [SBUser] {
        queue.sync {
            cache.getAll()
        }
    }

    func getUsers(for nickname: String) -> [SBUser] {
        queue.sync {
            cache.getAll().filter { nickname == $0.nickname }
        }
    }

    func getUser(for userId: String) -> (SBUser)? {
        queue.sync {
            cache.get(userId)
        }
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
