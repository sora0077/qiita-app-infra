//
//  ListUserFolloweesRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import QiitaKit
import BrightFutures
import RealmSwift
import QueryKit
import QiitaDomainInterface

extension QiitaRepositoryImpl {
    
    final class ListUserFollowees: UserListRepository {
        
        private let util: UserListRepositoryUtil<RefUserListEntity, QiitaKit.ListUserFollowees>
        
        init(session: QiitaSession, user: UserProtocol, pref: Realm -> PreferenceProtocol = PreferenceEntity.sharedPreference) {
            
            let key = ListUserFollowees.key(user)
            let user_id = user.id
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
                    QiitaKit.ListUserFollowees(id: user_id, page: page ?? 1)
                }
            )
        }
        
        static func key(suffix: UserProtocol) -> String {
            return "ListUserFollowees::\(suffix)"
        }
    }
}

extension QiitaRepositoryImpl.ListUserFollowees {
    
    func values() throws -> [UserProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        return util.update(force)
    }
}

