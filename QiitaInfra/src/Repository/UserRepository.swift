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

extension QiitaRepositoryImpl {
    
    final class User: UserRepository {
        
        private let listCache: NSCache = NSCache()
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
    }
}

extension QiitaRepositoryImpl.User {
    
    func itemStockers(item: ItemProtocol) -> UserListRepository {
        
        let key = QiitaRepositoryImpl.ListItemStockers.key(item)
        if let list = listCache.objectForKey(key) as? QiitaRepositoryImpl.ListItemStockers {
            return list
        }
        let list = QiitaRepositoryImpl.ListItemStockers(session: session, item: item)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func userFollowees(user: UserProtocol) -> UserListRepository {
        
        let key = QiitaRepositoryImpl.ListUserFollowees.key(user)
        if let list = listCache.objectForKey(key) as? QiitaRepositoryImpl.ListUserFollowees {
            return list
        }
        let list = QiitaRepositoryImpl.ListUserFollowees(session: session, user: user)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func userFollowers(user: UserProtocol) -> UserListRepository {
        
        let key = QiitaRepositoryImpl.ListUserFollowers.key(user)
        if let list = listCache.objectForKey(key) as? QiitaRepositoryImpl.ListUserFollowers {
            return list
        }
        let list = QiitaRepositoryImpl.ListUserFollowers(session: session, user: user)
        listCache.setObject(list, forKey: key)
        return list
    }
    
    func users() -> UserListRepository {
        
        let key = QiitaRepositoryImpl.ListUsers.key()
        if let list = listCache.objectForKey(key) as? QiitaRepositoryImpl.ListUsers {
            return list
        }
        let list = QiitaRepositoryImpl.ListUsers(session: session)
        listCache.setObject(list, forKey: key)
        return list
    }
}

extension QiitaRepositoryImpl.User {
    
    func cache(id: String) throws -> UserProtocol? {
        return try realm_sync {
            let realm = try GetRealm()
            return realm.objects(UserEntity)(key: id)
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
                        let realm = try GetRealm()
                        
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

extension QiitaRepositoryImpl.User {
    
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
