//
//  UserListRepository.swift
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

final class UserListRepositoryUtil<Entity: RefUserListEntityProtocol, Token: QiitaRequestToken where Entity: Object, Token: LinkProtocol, Token.Response == ([User], LinkMeta<Token>)> {
    
    private let session: QiitaSession
    private let query: NSPredicate
    
    private let entityProvider: (Realm, Token.Response) -> Entity
    private let tokenProvider: Int? -> Token
    
    private var running: Future<[UserProtocol], QiitaInfraError>?
    
    init(session: QiitaSession, query: NSPredicate, entityProvider: (Realm, Token.Response) -> Entity, tokenProvider: Int? -> Token) {
        self.session = session
        self.query = query
        
        self.entityProvider = entityProvider
        self.tokenProvider = tokenProvider
    }
    
    func values() throws -> [UserProtocol] {
        
        let realm = try Realm()
        guard let list = realm.objects(Entity).filter(query).first else {
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
    
    func update(force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
        
        func future() -> Future<[UserProtocol], QiitaInfraError> {
            let update = _update
            return running.map {
                $0.flatMap { _ in update(force) }
            } ?? update(force)
        }
        let f = future()
        self.running = f
        return f
    }
    
    private func _update(force: Bool) -> Future<[UserProtocol], QiitaInfraError> {
    
        let query = self.query
        let entityProvider = self.entityProvider
        let tokenProvider = self.tokenProvider
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
        
        func fetch(token: Token, isNew: Bool) -> Future<[UserProtocol], QiitaInfraError> {
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
                            let page = RefUserListPageEntity.create(realm, res)
                            realm.add(page)
                            entity.pages.append(page)
                            realm.add(entity, update: true)
                        } else {
                            entity = entityProvider(realm, res)
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
            
            return Realm.read(ImmediateOnMainExecutionContext)
                .mapError(QiitaInfraError.RealmError)
                .map { realm in
                    guard let page = realm.objects(Entity).filter(query).first?.pages.last else
                    {
                        return []
                    }
                    return page.users.map { $0 }
                }
        }
        
        if force {
            return fetch(tokenProvider(nil), isNew: true).flatMap(get)
        }
        
        return check().flatMap { res -> Future<[UserProtocol], QiitaInfraError> in
            guard let (token, isNew) = res else {
                return Future(value: [])
            }
            return fetch(token, isNew: isNew)
        }.flatMap(get)
    }
}


