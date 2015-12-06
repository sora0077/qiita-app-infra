//
//  AuthenticatedUserRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/24.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import BrightFutures
import QueryKit

extension QiitaRepositoryImpl {
    
    final class AuthenticatedUser: AuthenticatedUserRepository {
        
        private let session: QiitaSession
        private let prefProvider: Realm -> PreferenceProtocol
        
        init(session: QiitaSession, pref: Realm -> PreferenceProtocol = PreferenceEntity.sharedPreference) {
            self.session = session
            self.prefProvider = pref
        }
        
        var cache: AuthenticatedUserProtocol? {
            guard let realm = try? Realm(),
                let id = prefProvider(realm).authenticatedUserId
            else {
                return nil
            }
            return realm.objects(AuthenticatedUserEntity)(key: id)
        }
        
        var future: Future<AuthenticatedUserProtocol?, QiitaInfraError> {
            
            let prefProvider = self.prefProvider
            
            func get(_: AuthenticatedUserProtocol? = nil) -> Future<AuthenticatedUserProtocol?, QiitaInfraError> {
                return Realm.read().map { realm in
                    guard let id = prefProvider(realm).authenticatedUserId else {
                        return nil
                    }
                    return realm.objects(AuthenticatedUserEntity)
                        .filter(AuthenticatedUserEntity.id == id)
                        .filter(AuthenticatedUserEntity.ttl > AuthenticatedUserEntity.ttlLimit)
                        .first
                }.mapError(QiitaInfraError.RealmError)
            }
            
            func fetch() -> Future<AuthenticatedUserProtocol?, QiitaInfraError> {
                return session.request(GetAuthenticatedUser())
                    .mapError(QiitaInfraError.QiitaAPIError)
                    .flatMap { res in
                        realm {
                            let realm = try GetRealm()
                            realm.beginWrite()
                            
                            let entity = AuthenticatedUserEntity.create(realm, res)
                            realm.add(entity, update: true)
                            
                            var pref = prefProvider(realm)
                            pref.authenticatedUserId = entity.id
                            
                            try realm.commitWrite()
                            
                            return entity
                        }
                    }
            }
            
            return get() ?? fetch().flatMap(get)
        }
    }
}

