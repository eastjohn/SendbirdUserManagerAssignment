//
//  UserManagerImpl.swift
//
//
//  Created by 김요한 on 8/31/24.
//

import Foundation

final class UserManagerImpl: SBUserManager {
    private var session: Session?
    private let queue = SerialQueue(label: "com.userManager.serialQueue")
    private let internalNetworkClient = NetworkClientImpl()
    private let internalUserStorage = UserStorageImpl()

    var networkClient: SBNetworkClient { internalNetworkClient }
    var userStorage: SBUserStorage { internalUserStorage }

    func initApplication(applicationId: String, apiToken: String) {
        // initApplication은 completionHandler가 없어서 비동기가 아닌 sync로 처리.
        queue.sync {
            if shouldClearStorage(applicationId: applicationId) {
                internalUserStorage.clear()
            }
            let session = Session(applicationId: applicationId, apiToken: apiToken)
            internalNetworkClient.initialize(session: session)
            self.session = session
        }
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

extension UserManagerImpl {
    private func shouldClearStorage(applicationId: String) -> Bool {
        queue.preconditionOnQueue()
        return session?.applicationId != applicationId
    }
}
