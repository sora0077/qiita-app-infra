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

extension QiitaRepository.ListItemStockers {
    
    func values() throws -> [UserProtocol] {
        
        let realm = try Realm()
        guard let list = realm.objects(RefListItemStockersEntity)
            .filter("item_id = %@", item_id).first else
        {
            return []
        }
        var ret: [UserProtocol] = []
        for p in list.pages {
            for u in p.users {
                ret.append(u)
            }
        }
        return ret
    }
}

extension QiitaRepository.ListItemStockers {
    
    func update() -> Future<[UserProtocol], QiitaInfraError> {
        return update(force: false)
    }
    
    func update(force force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        
        
        func check() -> Future<(ListItemStockers, Bool)?, QiitaInfraError> {
            
            let item_id = self.item_id
            
            return realm {
                let realm = try Realm()
                
                let results = realm.objects(RefListItemStockersEntity)
                    .filter("item_id = %@", item_id)
                
                guard let list = results.filter("ttl > %@", RefListItemStockersEntity.ttlLimit).first else {
                    return (ListItemStockers(id: item_id), true)
                }
                guard let page = list.pages.last?.next_page.value else {
                    return nil
                }
                return (ListItemStockers(id: item_id, page: page), false)
            }
        }
        
        func fetch(token: ListItemStockers, isNew: Bool) -> Future<[UserProtocol], QiitaInfraError> {
            
            let item_id = self.item_id
            
            return session.request(token)
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try Realm()
                        
                        realm.beginWrite()
                        let results = realm.objects(RefListItemStockersEntity)
                            .filter("item_id = %@", item_id)
                        
                        if isNew {
                            realm.delete(results.flatMap { $0.pages.map { $0 } })
                            realm.delete(results)
                        }
                        
                        let entity: RefListItemStockersEntity
                        if let list = results.first where !isNew {
                            entity = list
                            let page = RefUserListPageEntity.create(realm, res)
                            realm.add(page)
                            entity.pages.append(page)
                            realm.add(entity, update: true)
                        } else {
                            entity = RefListItemStockersEntity.create(realm, item_id, res)
                            realm.add(entity, update: true)
                        }
                        
                        try realm.commitWrite()
                        
                        var ret: [UserProtocol] = []
                        for p in entity.pages {
                            for u in p.users {
                                ret.append(u)
                            }
                        }
                        return ret
                    }
            }
        }
        
        func get(_: [UserProtocol] = []) -> Future<[UserProtocol], QiitaInfraError> {
            
            let item_id = self.item_id
            return Realm.read(ImmediateOnMainExecutionContext)
                .mapError(QiitaInfraError.RealmError)
                .map { realm in
                    guard let page = realm.objects(RefListItemStockersEntity)
                        .filter("item_id = %@", item_id)
                        .first?.pages.last else
                    {
                        return []
                    }
                    return page.users.map { $0 }
            }
        }
        
        if force {
            let token = ListItemStockers(id: item_id)
            return fetch(token, isNew: true).flatMap(get)
        }
        
        return check().flatMap { res -> Future<[UserProtocol], QiitaInfraError> in
            guard let (token, isNew) = res else {
                return Future(value: [])
            }
            return fetch(token, isNew: isNew)
        }.flatMap(get)
    }
}


