//
//  MockUserManager.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import Foundation
import SendbirdUserManager

class MockUserManager: SBUserManager {
    static let shared = MockUserManager()
    
    var networkClient: SBNetworkClient
    var userStorage: SBUserStorage
    
    private var currentAppId: String?
    
    init() {
        self.networkClient = MockNetworkClient()
        self.userStorage = MockUserStorage()
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        // If the applicationId changes, clear all stored users
        if let currentAppId = currentAppId, currentAppId != applicationId {
            userStorage = MockUserStorage() // Reset the user storage
        }
        self.currentAppId = applicationId
        
        // Initialize network client or other components if needed
        // Note: In real-world applications, you might pass the API token to the network client here
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        let user = SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL)
        userStorage.upsertUser(user)
        completionHandler?(.success(user))
//
//        // Define the request
////        let request = Request(method: .post, path: "/createUser", body: params)
//
//        networkClient.execute(request: request) { response in
//            switch response {
//            case .success(let data):
//                // Convert data to user object
//                let user = ... // Deserialize from data
//                self.userStorage.setUser(user, for: user.id)
//                completionHandler(.success(user))
//            case .failure(let error):
//                completionHandler(.failure(error))
//            }
//        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        guard params.count <= 10 else {
            completionHandler?(.failure(UserManagerError.exceededMaximumUsers))
            return
        }
        let users = params.map { SBUser(userId: $0.userId, nickname: $0.nickname, profileURL: $0.profileURL) }
        users.forEach { userStorage.upsertUser($0) }
        completionHandler?(.success(users))
        
//        // For simplicity, let's assume you can send multiple users in one request
//        let request = Request(method: .post, path: "/createUsers", body: params)
//
//        networkClient.execute(request: request) { response in
//            switch response {
//            case .success(let data):
//                // Convert data to user objects
//                let users = ... // Deserialize from data
//                for user in users {
//                    self.userStorage.setUser(user, for: user.id)
//                }
//                completionHandler(.success(users))
//            case .failure(let error):
//                completionHandler(.failure(error))
//            }
//        }
    }
    
    func updateUser(params: SendbirdUserManager.UserUpdateParams, completionHandler: ((SendbirdUserManager.UserResult) -> Void)?) {
        let user = SBUser(userId: params.userId, nickname: params.nickname, profileURL: params.profileURL)
        userStorage.upsertUser(user)
        completionHandler?(.success(user))
//
//        let request = Request(method: .patch, path: "/updateUser/\(userId)", body: params)
//
//        networkClient.execute(request: request) { response in
//            switch response {
//            case .success(let data):
//                // Convert data to user object
//                let user = ... // Deserialize from data
//                self.userStorage.setUser(user, for: user.id) // Upsert the user
//                completionHandler(.success(user))
//            case .failure(let error):
//                completionHandler(.failure(error))
//            }
//        }

    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        if let cachedUser = userStorage.getUser(for: userId) {
            completionHandler?(.success(cachedUser))
            return
        }

        
//        let request = Request(method: .get, path: "/getUser/\(userId)")
//
//        networkClient.execute(request: request) { response in
//            switch response {
//            case .success(let data):
//                // Convert data to user object
//                let user = ... // Deserialize from data
//                self.userStorage.setUser(user, for: user.id) // Cache the user
//                completionHandler(.success(user))
//            case .failure(let error):
//                completionHandler(.failure(error))
//            }
//        }
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
//        let request = Request(method: .get, path: "/getUsers", parameters: ["nickname": nicknameMatches, "limit": "10"])
//
//        networkClient.execute(request: request) { response in
//            switch response {
//            case .success(let data):
//                // Convert data to user objects
//                let users = ... // Deserialize from data
//                for user in users {
//                    self.userStorage.setUser(user, for: user.id) // Cache the users
//                }
//                completionHandler(.success(users))
//            case .failure(let error):
//                completionHandler(.failure(error))
//            }
//        }
    }
}
