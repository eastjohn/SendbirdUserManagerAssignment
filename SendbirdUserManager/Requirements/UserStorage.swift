//
//  UserStorage.swift
//  
//
//  Created by Sendbird
//

import Foundation

/// Sendbird User 를 관리하기 위한 storage class입니다
public protocol SBUserStorage {
    init()
    
    /// in-memory cache에 user를 userId key를 사용하여 저장합니다.
    func setUser(_ user: SBUser, for userId: String)
    
    /// 현재 저장되어있는 모든 유저를 반환합니다
    func getUsers() -> [SBUser]
    /// 현재 저장되어있는 유저들 중에 지정된 userId를 가진 유저를 반환합니다. 
    func getUser(for userId: String) -> (SBUser)?
}
