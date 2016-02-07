//
//  CommentRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import BrightFutures
import QueryKit
import QiitaDomainInterface

extension QiitaRepositoryImpl {
    
    final class Comment: CommentRepository {
        
        private let listCache: NSCache = NSCache()
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
    }
}

extension QiitaRepositoryImpl.Comment {
    
    func create(item: ItemProtocol, body: String) -> Future<CommentProtocol, QiitaInfraError> {
        
        return session.request(CreateItemComment(id: item.id, body: body))
            .mapError(QiitaInfraError.QiitaAPIError)
            .flatMap { res in
                realm {
                    let realm = try GetRealm()
                    realm.beginWrite()
                    
                    let entity = CommentEntity.create(realm, res)
                    realm.add(entity, update: true)
                    
                    try realm.commitWrite()
                    
                    return entity
                }
            }
    }
    
    func update(comment: CommentProtocol, body: String) -> Future<CommentProtocol, QiitaInfraError> {
        
        let comment_id = comment.id
        return session.request(UpdateComment(id: comment_id, body: body))
            .mapError(QiitaInfraError.QiitaAPIError)
            .flatMap { res in
                realm {
                    let realm = try GetRealm()
                    realm.beginWrite()
                    
                    let entity = CommentEntity.create(realm, res)
                    realm.add(entity, update: true)
                    
                    try realm.commitWrite()
                    
                    return entity
                }
            }
    }
    
    func delete(comment: CommentProtocol) -> Future<(), QiitaInfraError>  {
        
        let comment_id = comment.id
        return session.request(DeleteComment(id: comment_id))
            .mapError(QiitaInfraError.QiitaAPIError)
            .flatMap { res in
                realm {
                    let realm = try GetRealm()
                    
                    if let entity = realm.objects(CommentEntity).filter("id = %@", comment_id).first {
                        realm.beginWrite()
                        realm.delete(entity)
                        try realm.commitWrite()
                    }
                }
            }
    }
    
}

extension QiitaRepositoryImpl.Comment {
    
    func itemComments(item: ItemProtocol) -> CommentListRepository {
        
        let key = QiitaRepositoryImpl.ListItemComments.key(item)
        if let list = listCache.objectForKey(key) as? CommentListRepository {
            return list
        }
        let list = QiitaRepositoryImpl.ListItemComments(session: session, item: item)
        listCache.setObject(list, forKey: key)
        return list
    }
}

extension QiitaRepositoryImpl.Comment {
    
    func cache(id: String) throws -> CommentProtocol? {
        return try realm_sync {
            let realm = try GetRealm()
            return realm.objectForPrimaryKey(CommentEntity.self, key: id)
        }
    }
    
    func get(id: String) -> Future<CommentProtocol?, QiitaInfraError> {
        
        func get(_: CommentProtocol? = nil) -> Future<CommentProtocol?, QiitaInfraError> {
            
            return Realm.read(Queue.main.context).map { realm in
                realm.objects(CommentEntity)
                    .filter(CommentEntity.id == id)
                    .filter(CommentEntity.ttl > CommentEntity.ttlLimit)
                    .first
                }.mapError(QiitaInfraError.RealmError)
        }
        
        func fetch() -> Future<CommentProtocol?, QiitaInfraError> {
            
            return session.request(GetComment(id: id))
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try GetRealm()
                        
                        let entity = CommentEntity.create(realm, res)
                        
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


extension QiitaRepositoryImpl.Comment {
    
    func thank(item: ItemProtocol) -> Future<(), QiitaInfraError> {
        
        return session.request(ThankComment(id: item.id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
    
    func unthank(item: ItemProtocol) -> Future<(), QiitaInfraError> {
        
        return session.request(UnthankComment(id: item.id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
}
