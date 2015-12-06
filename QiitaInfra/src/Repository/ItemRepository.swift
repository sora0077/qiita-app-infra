//
//  ItemRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/30.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import BrightFutures
import QueryKit

extension QiitaRepositoryImpl {
    
    final class Item: ItemRepository {
        
        private let listCache: NSCache = NSCache()
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
    }
}

extension QiitaRepositoryImpl.Item {
    
    func cache(id: String) throws -> ItemProtocol? {
        return try realm_sync {
            let realm = try GetRealm()
            return realm.objects(ItemEntity)(key: id)
        }
    }
    
    func get(id: String) -> Future<ItemProtocol?, QiitaInfraError> {
        
        func get(_: ItemProtocol? = nil) -> Future<ItemProtocol?, QiitaInfraError> {
            
            return Realm.read(Queue.main.context).map { realm in
                realm.objects(ItemEntity)
                    .filter(ItemEntity.id == id)
                    .filter(ItemEntity.ttl > ItemEntity.ttlLimit)
                    .first
                }.mapError(QiitaInfraError.RealmError)
        }
        
        func fetch() -> Future<ItemProtocol?, QiitaInfraError> {
            
            return session.request(GetItem(id: id))
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try GetRealm()
                        
                        let entity = ItemEntity.create(realm, res)
                        
                        realm.beginWrite()
                        realm.add(entity, update: true)
                        try realm.commitWrite()
                        
                        return entity
                    }
            }
        }
        
        return get() ?? fetch().flatMap(get)
    }
}

extension QiitaRepositoryImpl.Item {
    
    func create(body: String, title: String, coediting: Bool = false, gist: Bool = false, tweet: Bool = false, `private`: Bool = false, tags: [String]) -> Future<ItemProtocol?, QiitaInfraError> {
        
        return session.request(
                CreateItem(
                    body: body,
                    coediting: coediting,
                    gist: gist,
                    `private`: `private`,
                    tags: tags.map { Tagging(name: $0) },
                    title: title,
                    tweet: tweet
                )
            )
            .mapError(QiitaInfraError.QiitaAPIError)
            .flatMap { res in
                realm {
                    let realm = try GetRealm()
                    
                    let entity = ItemEntity.create(realm, res)
                    
                    realm.beginWrite()
                    realm.add(entity, update: true)
                    try realm.commitWrite()
                    
                    return entity
                }
            }
    }
    
    func update(item: ItemProtocol, body: String? = nil, title: String? = nil) {
        
    }
}
