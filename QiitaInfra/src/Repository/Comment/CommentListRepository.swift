//
//  CommentListRepository.swift
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

struct CommentListRepositoryUtil<Entity: RefCommentListEntity, Token: QiitaRequestToken where Entity: Object, Token: LinkProtocol, Token.Response == ([Comment], LinkMeta<Token>)> {
    
    private let session: QiitaSession
    private let query: NSPredicate
    
    init(session: QiitaSession, query: NSPredicate) {
        self.session = session
        self.query = query
    }
    
    func values() throws -> [CommentProtocol] {
        
        let realm = try Realm()
        guard let list = realm.objects(Entity).filter(query).first else {
            return []
        }
        var ret: [CommentProtocol] = []
        for p in list.pages {
            for c in p.comments {
                ret.append(c)
            }
        }
        return ret
    }
    
    func update(force: Bool)(entityProvider: (Realm, Token.Response) -> Entity, tokenProvider: Int? -> Token) -> Future<[CommentProtocol], QiitaInfraError> {
        
        let query = self.query
        func check() -> Future<(Token, Bool)?, QiitaInfraError> {
            return realm {
                let realm = try Realm()
                
                let results = realm.objects(Entity).filter(query)
                guard let list = results.filter(Entity.ttl > Entity.ttlLimit).first else {
                    return (tokenProvider(nil), true)
                }
                guard let page = list.pages.last?.next_page.value else {
                    return nil
                }
                return (tokenProvider(page), false)
            }
        }
        
        func fetch(token: Token, isNew: Bool) -> Future<[CommentProtocol], QiitaInfraError> {
            return session.request(token)
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try Realm()
                        
                        realm.beginWrite()
                        let results = realm.objects(Entity).filter(query)
                        
                        if isNew {
                            realm.delete(results.flatMap { $0.pages.map { $0 } })
                            realm.delete(results)
                        }
                        
                        let entity: Entity
                        if let list = results.first where !isNew {
                            entity = list
                            let page = RefCommentListPageEntity.create(realm, res)
                            realm.add(page)
                            entity.pages.append(page)
                            realm.add(entity, update: true)
                        } else {
                            entity = entityProvider(realm, res)
                            realm.add(entity, update: true)
                        }
                        
                        try realm.commitWrite()
                        
                        var ret: [CommentProtocol] = []
                        for p in entity.pages {
                            for u in p.comments {
                                ret.append(u)
                            }
                        }
                        return ret
                    }
            }
        }
        
        func get(_: [CommentProtocol] = []) -> Future<[CommentProtocol], QiitaInfraError> {
            
            return Realm.read(ImmediateOnMainExecutionContext)
                .mapError(QiitaInfraError.RealmError)
                .map { realm in
                    guard let page = realm.objects(Entity).filter(query).first?.pages.last else {
                        return []
                    }
                    return page.comments.map { $0 }
            }
        }
        
        if force {
            return fetch(tokenProvider(nil), isNew: true).flatMap(get)
        }
        
        return check().flatMap { res -> Future<[CommentProtocol], QiitaInfraError> in
            guard let (token, isNew) = res else {
                return Future(value: [])
            }
            return fetch(token, isNew: isNew)
        }.flatMap(get)
    }
}