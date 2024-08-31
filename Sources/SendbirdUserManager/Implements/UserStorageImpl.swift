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
