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
        guard params.count <= Constants.maximumUserCount else {
            completionHandler?(.failure(SBUserManagerError.creatingUsersExceeded))
            return
        }
        var params = params
        let firstParam = params.removeFirst()
        queue.run { [weak self] in
            guard let ss = self else {
                completionHandler?(.failure(SBUserManagerError.nilSelf))
                return
            }
            guard let session = ss.session else {
                completionHandler?(.failure(SBUserManagerError.notInitialized))
                return
            }
            ss.createUser(params: firstParam) { [weak weakSelf = ss, taskSessionId = session.applicationId] result in
                guard let ss = weakSelf else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                    completionHandler?(.failure(SBUserManagerError.invalidSession))
                    return
                }
                ss.continueCreateUser(params: params, results: ContinueCreateUserResults(result: result, param: firstParam), taskSessionId: taskSessionId) { [weak weakSelf = ss] result in
                    guard let ss = weakSelf else {
                        completionHandler?(.failure(SBUserManagerError.nilSelf))
                        return
                    }
                    ss.handleContinueCreatedUserResult(result: result, completionHandler: completionHandler)
                }
            }
        }
    }

    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        do {
            try checkUserUpdateParams(params)
        } catch {
            completionHandler?(.failure(error))
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
            ss.networkClient.request(request: UpdateUserRequest(userId: params.userId, nickname: params.nickname, profileUrl: params.profileURL)) { [weak weakSelf = ss, taskSessionId = session.applicationId] result in
                guard let ss = weakSelf else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                ss.handleUpdatedUserResult(result: result, taskSessionId: taskSessionId, completionHandler: completionHandler)
            }
        }
    }

    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        guard !userId.isEmpty else {
            completionHandler?(.failure(SBUserManagerError.emptyUserId))
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
            if let user = ss.userStorage.getUser(for: userId) {
                completionHandler?(.success(user))
            } else {
                ss.networkClient.request(request: GetUserRequest(userId: userId)) { [weak weakSelf = ss, taskSessionId = session.applicationId] result in
                    guard let ss = weakSelf else {
                        completionHandler?(.failure(SBUserManagerError.nilSelf))
                        return
                    }
                    ss.handleGotUserResult(result: result, taskSessionId: taskSessionId, completionHandler: completionHandler)
                }
            }
        }
    }

    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        guard !nicknameMatches.isEmpty else {
            completionHandler?(.failure(SBUserManagerError.emptyNickname))
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
            ss.networkClient.request(request: GetUsersRequest(nickname: nicknameMatches, limit: Constants.queryLimitCount)) { [weak weakSelf = ss, taskSessionId = session.applicationId]  result in
                guard let ss = weakSelf else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                ss.handleGotUsersResult(result: result, taskSessionId: taskSessionId, completionHandler: completionHandler)
            }
        }
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

    private func checkUserUpdateParams(_ params: UserUpdateParams) throws {
        if params.userId.isEmpty {
            throw SBUserManagerError.emptyUserId
        }
        if params.userId.count > Constants.maximumLengthOfUserId {
            throw SBUserManagerError.userIdLengthExceeded
        }
        if let nickname = params.nickname, nickname.count > Constants.maximumLengthOfNickname {
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
    
    private func continueCreateUser(params: [UserCreationParams], results: ContinueCreateUserResults, taskSessionId: String, completionHandler: @escaping (Result<ContinueCreateUserResults, Error>) -> Void) {
        guard let firstParam = params.first else {
            completionHandler(.success(results))
            return
        }
        var params = params
        params.removeFirst()
        queue.asyncAfter(deadline: .now() + Constants.nextRequestTime) { [weak self] in
            guard let ss = self else {
                completionHandler(.failure(SBUserManagerError.nilSelf))
                return
            }
            guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                completionHandler(.failure(SBUserManagerError.invalidSession))
                return
            }
            ss.createUser(params: firstParam, completionHandler: { [weak weakSelf = ss] result in
                guard let ss = weakSelf else {
                    completionHandler(.failure(SBUserManagerError.nilSelf))
                    return
                }
                ss.queue.run { [weak weakSelf = ss] in
                    guard let ss = weakSelf else {
                        completionHandler(.failure(SBUserManagerError.nilSelf))
                        return
                    }
                    guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                        completionHandler(.failure(SBUserManagerError.invalidSession))
                        return
                    }
                    let results =
                    switch result {
                    case .success(let user):
                        results.appendingCreatedUser(user)

                    case .failure(let error):
                        results.appendingFailedUser(.init(userId: firstParam.userId, nickname: firstParam.nickname, profileURL: firstParam.profileURL), error: error)
                    }
                    ss.continueCreateUser(params: params, results: results, taskSessionId: taskSessionId, completionHandler: completionHandler)
                }
            })
        }
    }

    private func handleContinueCreatedUserResult(
        result: Result<UserManagerImpl.ContinueCreateUserResults, Error>,
        completionHandler: ((UsersResult) -> Void)?
    ) {
        switch result {
        case .success(let results):
            queue.run { [weak self] in
                guard let ss = self else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                results.createdUsers.forEach {
                    ss.userStorage.upsertUser($0)
                }
                if results.failedUsers.isEmpty {
                    completionHandler?(.success(results.createdUsers))
                } else {
                    completionHandler?(.failure(SBUserManagerError.failedContinueCreateUsers(createdUsers: results.createdUsers, failedUsers: results.failedUsers)))
                }
            }

        case .failure(let error):
            completionHandler?(.failure(error))
        }
    }

    private func handleUpdatedUserResult(
        result: Result<UpdateUserRequest.Response, Error>,
        taskSessionId: String,
        completionHandler: ((UserResult) -> Void)?
    ) {
        switch result {
        case .success(let response):
            queue.run { [weak self] in
                guard let ss = self else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                    completionHandler?(.failure(SBUserManagerError.invalidSession))
                    return
                }
                let user = SBUser(userId: response.userId, nickname: response.nickname, profileURL: response.profileUrl)
                ss.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            }

        case .failure(let error):
            completionHandler?(.failure(error))
        }
    }

    private func handleGotUserResult(
        result: Result<GetUserRequest.Response, Error>,
        taskSessionId: String,
        completionHandler: ((UserResult) -> Void)?
    ) {
        switch result {
        case .success(let response):
            queue.run { [weak self] in
                guard let ss = self else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                    completionHandler?(.failure(SBUserManagerError.invalidSession))
                    return
                }
                let user = SBUser(userId: response.userId, nickname: response.nickName, profileURL: response.profileUrl)
                ss.userStorage.upsertUser(user)
                completionHandler?(.success(user))
            }

        case .failure(let error):
            completionHandler?(.failure(error))
        }
    }

    private func handleGotUsersResult(
        result: Result<GetUsersRequest.Response, Error>,
        taskSessionId: String,
        completionHandler: ((UsersResult) -> Void)?
    ) {
        switch result {
        case .success(let response):
            queue.run { [weak self] in
                guard let ss = self else {
                    completionHandler?(.failure(SBUserManagerError.nilSelf))
                    return
                }
                guard ss.isValidTaskSession(sessionId: taskSessionId) else {
                    completionHandler?(.failure(SBUserManagerError.invalidSession))
                    return
                }
                let users = response.users.map {
                    SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileUrl)
                }
                users.forEach {
                    ss.userStorage.upsertUser($0)
                }
                completionHandler?(.success(users))
            }

        case .failure(let error):
            completionHandler?(.failure(error))
        }
    }
}

extension UserManagerImpl {
    private enum Constants {
        static let maximumLengthOfUserId = 80
        static let maximumLengthOfNickname = 80
        static let maximumLengthOfProfileUrl = 2048
        static let maximumUserCount = 10

        static let nextRequestTime: TimeInterval = 1.0
        static let queryLimitCount = 100
    }
    
    private struct ContinueCreateUserResults {
        let createdUsers: [SBUser]
        let failedUsers: [(SBUser, Error)]

        init(result: UserResult, param: UserCreationParams) {
            switch result {
            case .success(let user):
                createdUsers = [user]
                failedUsers = []

            case .failure(let error):
                failedUsers = [(.init(userId: param.userId, nickname: param.nickname, profileURL: param.profileURL), error)]
                createdUsers = []
            }
        }

        private init(createdUsers: [SBUser], failedUsers: [(SBUser, Error)]) {
            self.createdUsers = createdUsers
            self.failedUsers = failedUsers
        }

        func appendingCreatedUser(_ user: SBUser) -> Self {
            .init(createdUsers: createdUsers + [user], failedUsers: failedUsers)
        }

        func appendingFailedUser(_ user: SBUser, error: Error) -> Self {
            .init(createdUsers: createdUsers, failedUsers: failedUsers + [(user, error)])
        }
    }
}
