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
        
        private let session: QiitaSession
        
        private let item_id: String
        
        private let util: UserListRepositoryUtil<RefListItemStockersEntity, QiitaKit.ListItemStockers>
        
        init(session: QiitaSession, item: ItemProtocol) {
            self.session = session
            self.item_id = item.id
            
            self.util = UserListRepositoryUtil(
                session: session,
                query: RefListItemStockersEntity.item_id == item.id
            )
        }
    }
}

extension QiitaRepository.ListItemStockers {
    
    func values() throws -> [UserProtocol] {
        return try util.values()
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        
        let item_id = self.item_id
        return util.update(force)(
            entityProvider: { realm, res in
                RefListItemStockersEntity.create(realm, item_id, res)
            },
            tokenProvider: { page in
                ListItemStockers(id: item_id, page: page ?? 1)
            }
        )
    }
}
