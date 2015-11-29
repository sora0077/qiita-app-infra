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
import QueryKit

extension QiitaRepository {
    
    final class User: UserRepository {
        
        private let listCache: NSCache = NSCache()
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
    }
}

extension QiitaRepository.User {
    
    func itemStockers(item: ItemProtocol) -> UserListRepository {
        
        let key = QiitaRepository.ListItemStockers.key(item)
        if let list = listCache.objectForKey(key) as? QiitaRepository.ListItemStockers {
            return list
        }
        let list = QiitaRepository.ListItemStockers(session: session, item: item)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func userFollowees(user: UserProtocol) -> UserListRepository {
        
        let key = QiitaRepository.ListUserFollowees.key(user)
        if let list = listCache.objectForKey(key) as? QiitaRepository.ListUserFollowees {
            return list
        }
        let list = QiitaRepository.ListUserFollowees(session: session, user: user)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func userFollowers(user: UserProtocol) -> UserListRepository {
        
        let key = QiitaRepository.ListUserFollowers.key(user)
        if let list = listCache.objectForKey(key) as? QiitaRepository.ListUserFollowers {
            return list
        }
        let list = QiitaRepository.ListUserFollowers(session: session, user: user)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func users() -> UserListRepository {
        
        let key = QiitaRepository.ListUsers.key()
        if let list = listCache.objectForKey(key) as? QiitaRepository.ListUsers {
            return list
        }
        let list = QiitaRepository.ListUsers(session: session)
        listCache.setObject(list, forKey: key)
        return list
    }
}

extension QiitaRepository.User {
    
    func cache(id: String) throws -> UserProtocol? {
        return try realm_sync {
            let realm = try Realm()
            return realm.objectForPrimaryKey(UserEntity.self, key: id)
        }
    }
    
    func get(id: String) -> Future<UserProtocol?, QiitaInfraError> {
        
        func get(_: UserProtocol? = nil) -> Future<UserProtocol?, QiitaInfraError> {
            
            return Realm.read(Queue.main.context).map { realm in
                realm.objects(UserEntity)
                    .filter(UserEntity.id == id)
                    .filter(UserEntity.ttl > UserEntity.ttlLimit)
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
        return session.request(FollowUser(id: user.id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
    
    func unfollow(user: UserProtocol) -> Future<(), QiitaInfraError> {
        return session.request(UnfollowUser(id: user.id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
    
    func following(user: UserProtocol) -> Future<(), QiitaInfraError> {
        return session.request(GetUserFollowing(id: user.id))
            .mapError(QiitaInfraError.QiitaAPIError)
    }
}
