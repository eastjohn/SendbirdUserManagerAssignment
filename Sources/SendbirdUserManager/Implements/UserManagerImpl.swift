//
//  UserManagerImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class UserManagerImpl: SBUserManager {
    var networkClient: SBNetworkClient = NetworkClientImpl()
    var userStorage: SBUserStorage = UserStorageImpl()

    func initApplication(applicationId: String, apiToken: String) {
    }

    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
    }

    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
    }

    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
    }

    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
    }

    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
    }
}
