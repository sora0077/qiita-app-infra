//
//  ListUsersRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/29.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit
import BrightFutures
import RealmSwift
import QueryKit

extension QiitaRepository {
    
    final class ListUsers: UserListRepository {
        
        private let util: UserListRepositoryUtil<RefUserListEntity, QiitaKit.ListUsers>
        
        init(session: QiitaSession, pref: Realm -> PreferenceProtocol = PreferenceEntity.sharedPreference) {
            
            
            let key = "ListUsers"
            self.util = UserListRepositoryUtil(
                session: session,
                query: RefUserListEntity.key == key,
                versionProvider: { realm in
                    pref(realm).launchCount
                },
                entityProvider: { realm, res in
                    RefUserListEntity.create(realm, key, res)
                },
                tokenProvider: { page in
                    QiitaKit.ListUsers(page: page ?? 1)
                }
            )
        }
        
        static func key() -> String {
            return "ListUsers"
        }
    }
}

extension QiitaRepository.ListUsers {
    
    func values() throws -> [UserProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        return util.update(force)
    }
}


