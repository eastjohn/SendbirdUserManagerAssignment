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
        do {
            try checkUserCreateParams(params)
        } catch {
            completionHandler?(.failure(error))
            return
        }
        guard userStorage.getUser(for: params.userId) == nil else {
            completionHandler?(.failure(SBUserManagerError.alreadyExistUser))
            return
        }
        queue.run { [weak self] in
            guard let ss = self else {
                completionHandler?(.failure(SBUserManagerError.nilSelf))
                return
            }
            guard let session = ss.session else {
                completionHandler?(.failure(SBUserManagerError.notInitialized))
                return
            }
            ss.networkClient.request(request: CreateUserRequest(userId: params.userId, nickname: params.nickname, profileUrl: params.profileURL)) { [taskSessionId = session.applicationId] result in
                guard let ss = self else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                ss.handleCreatedUserResult(result, taskSessionId: taskSessionId, completionHandler: completionHandler)
            }
        }
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

    private func checkUserCreateParams(_ params: UserCreationParams) throws {
        if params.userId.isEmpty {
            throw SBUserManagerError.emptyUserId
        }
        if params.userId.count > Constants.maximumLengthOfUserId {
            throw SBUserManagerError.userIdLengthExceeded
        }
        if params.nickname.count > Constants.maximumLengthOfNickname {
            throw SBUserManagerError.nicknameLengthExceeded
        }
        if let profileURL = params.profileURL, profileURL.count > Constants.maximumLengthOfProfileUrl {
            throw SBUserManagerError.profileUrlLengthExcceded
        }
    }

    private func isValidTaskSession(sessionId: String) -> Bool {
        queue.preconditionOnQueue()
        return session?.applicationId == sessionId
        
    }

    private func handleCreatedUserResult(
        _ result: Result<CreateUserRequest.Response, Error>,
        taskSessionId: String,
        completionHandler: ((UserResult) -> Void)?
    ) {
        queue.run { [weak self] in
            guard let ss = self else {
                completionHandler?(.failure(SBUserManagerError.nilSelf))
                return
            }
            guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                completionHandler?(.failure(SBUserManagerError.invalidSession))
                return
            }
            switch result {
            case .success(let response):
                let user = SBUser(userId: response.userId, nickname: response.nickname, profileURL: response.profileUrl)
                ss.userStorage.upsertUser(user)
                completionHandler?(.success(user))

            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
}

extension UserManagerImpl {
    private enum Constants {
        static let maximumLengthOfUserId = 80
        static let maximumLengthOfNickname = 80
        static let maximumLengthOfProfileUrl = 2048
    }
}
