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

extension QiitaRepository {
    
    final class ListItemStockers: UserListRepository {
        
        private let session: QiitaSession
        
        private let item_id: String
        
        init(session: QiitaSession, item: ItemProtocol) {
            self.session = session
            self.item_id = item.id
        }
    }
}

import QueryKit

extension QiitaRepository.ListItemStockers {
    
    func values() throws -> [UserProtocol] {
        return try _values(RefListItemStockersEntity.self, query: RefListItemStockersEntity.item_id == self.item_id)
    }
}

extension QiitaRepository.ListItemStockers {
    
    func update() -> Future<[UserProtocol], QiitaInfraError> {
        return update(force: false)
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        
        let item_id = self.item_id
        return _update(
            session, force: force, query: RefListItemStockersEntity.item_id == item_id
        )(
            entityProvider: { realm, res -> RefListItemStockersEntity in
                RefListItemStockersEntity.create(realm, item_id, res)
            },
            tokenProvider: { page -> ListItemStockers in
                ListItemStockers(id: item_id, page: page ?? 1)
            }
        )
    }
}


