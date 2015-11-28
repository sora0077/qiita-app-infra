//
//  ListUserFollowersRepository.swift
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

extension QiitaRepository {
    
    final class ListUserFollowers: UserListRepository {
        
        private let util: UserListRepositoryUtil<RefUserListEntity, QiitaKit.ListUserFollowers>
        
        init(session: QiitaSession, user: UserProtocol) {
            
            let key = "ListUserFollowers::\(user.id)"
            let user_id = user.id
            self.util = UserListRepositoryUtil(
                session: session,
                query: RefUserListEntity.key == key,
                entityProvider: { realm, res in
                    RefUserListEntity.create(realm, key, res)
                },
                tokenProvider: { page in
                    QiitaKit.ListUserFollowers(id: user_id, page: page ?? 1)
                }
            )
        }
    }
}

extension QiitaRepository.ListUserFollowers {
    
    func values() throws -> [UserProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        return util.update(force)
    }
}


