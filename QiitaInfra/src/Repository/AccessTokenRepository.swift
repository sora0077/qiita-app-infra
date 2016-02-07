//
//  AccessTokenRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/20.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import BrightFutures
import QiitaDomainInterface

extension QiitaRepositoryImpl {
    
    final class AccessToken: AccessTokenRepository {
        
        var cache: AccessTokenProtocol? {
            let realm = try? GetRealm()
            return realm?.objects(AccessTokenEntity)(key: 1)
        }
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
        func observe(scopes: [QiitaKit.AccessToken.Scope], scheme: String, state: String? = nil) -> Future<AccessTokenProtocol, QiitaInfraError> {
            return session.oauthAuthorize(scopes, scheme: scheme, state: state)
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try GetRealm()
                        
                        realm.beginWrite()
                        
                        let entity = AccessTokenEntity()
                        entity.client_id = res.client_id
                        entity.scopes = res.scopes
                        entity.token = res.token
                      
                        realm.add(entity, update: true)
                        
                        try realm.commitWrite()
                        
                        return entity
                    }
                }
        }
        
        func delete() -> Future<(), QiitaInfraError> {
            return session.oauthDelete()
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try GetRealm()
                        realm.beginWrite()
                        if let obj = realm.objects(AccessTokenEntity)(key: 1) {
                            realm.delete(obj)
                        }
                        try realm.commitWrite()
                    }
                }
        }
    }
}

