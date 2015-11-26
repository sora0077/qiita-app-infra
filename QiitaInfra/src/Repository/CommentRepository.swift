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


extension QiitaRepository {
    
    final class Comment: CommentRepository {
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
        func list(item: ItemProtocol) -> CommentListRepository {
            
            return QiitaRepository.CommentList(session: session, item: item)
        }
        
        func create(item: ItemProtocol, body: String) -> Future<CommentProtocol, QiitaInfraError> {
            
            return session.request(CreateItemComment(id: item.id, body: body))
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try Realm()
                        realm.beginWrite()
                        
                        let entity = CommentEntity.create(realm, res)
                        realm.add(entity, update: true)
                        
                        try realm.commitWrite()
                        
                        return entity
                    }
                }
        }
        
        func delete(comment: CommentProtocol) -> Future<(), QiitaInfraError>  {
            
            return session.request(DeleteComment(id: comment.id))
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try Realm()
                        
                        if let entity = realm.objects(CommentEntity).filter("id = %@", comment.id).first {
                            realm.beginWrite()
                            realm.delete(entity)
                            try realm.commitWrite()
                        }
                    }
                }
        }
        
        func get(id: String) -> Future<CommentProtocol?, QiitaInfraError> {
         
            func get(_: CommentProtocol? = nil) -> Future<CommentProtocol?, QiitaInfraError> {
                
                return Realm.read(Queue.main.context).map { realm in
                    realm.objects(CommentEntity)
                        .filter("id = %@", id)
                        .filter("ttl > %@", CommentEntity.ttl)
                        .first
                    }.mapError(QiitaInfraError.RealmError)
            }
            
            func fetch() -> Future<CommentProtocol?, QiitaInfraError> {
                
                return session.request(GetComment(id: id))
                    .mapError(QiitaInfraError.QiitaAPIError)
                    .flatMap { res in
                        realm {
                            let realm = try Realm()
                            
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
}