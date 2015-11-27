//
//  UserRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/26.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import BrightFutures


extension QiitaRepository {
    
    final class User: UserRepository {
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
    }
}

extension QiitaRepository.User {
    
    func get(id: String) -> Future<UserProtocol?, QiitaInfraError> {
        
        func get(_: UserProtocol? = nil) -> Future<UserProtocol?, QiitaInfraError> {
            
            return Realm.read(Queue.main.context).map { realm in
                realm.objects(UserEntity)
                    .filter("id = %@", id)
                    .filter("ttl > %@", UserEntity.ttl)
                    .first
                }.mapError(QiitaInfraError.RealmError)
        }
        
        func fetch() -> Future<UserProtocol?, QiitaInfraError> {
            
            return session.request(GetUser(id: id))
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try Realm()
                        
                        let entity = UserEntity.create(realm, res)
                        
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

extension QiitaRepository.User {
    
    func follow(user: UserProtocol) -> Future<(), QiitaInfraError> {
        
        let user_id = user.id
        
        return session.request(FollowUser(id: user_id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
    
    func unfollow(user: UserProtocol) -> Future<(), QiitaInfraError> {
        
        let user_id = user.id
        
        return session.request(UnfollowUser(id: user_id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
}
