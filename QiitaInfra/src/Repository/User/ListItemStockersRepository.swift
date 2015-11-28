//
//  ListItemStockersRepository.swift
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
    
    final class ListItemStockers: UserListRepository {
        
        private let util: UserListRepositoryUtil<RefUserListEntity, QiitaKit.ListItemStockers>
        
        init(session: QiitaSession, item: ItemProtocol) {
            
            let key = "ListItemStockers::\(item.id)"
            let item_id = item.id
            self.util = UserListRepositoryUtil(
                session: session,
                query: RefUserListEntity.key == key,
                entityProvider: { realm, res in
                    RefUserListEntity.create(realm, key, res)
                },
                tokenProvider: { page in
                    QiitaKit.ListItemStockers(id: item_id, page: page ?? 1)
                }
            )
        }
    }
}

extension QiitaRepository.ListItemStockers {
    
    func values() throws -> [UserProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        return util.update(force)
    }
}
