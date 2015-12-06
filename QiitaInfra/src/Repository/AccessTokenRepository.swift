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

extension QiitaRepositoryImpl {
    
    final class AccessToken: AccessTokenRepository {
        
        var cache: AccessTokenProtocol? {
            let realm = try? Realm()
            return realm?.objects(AccessTokenEntity).first
        }
        
        private let session: QiitaSession
        
        init(session: QiitaSession) {
            self.session = session
        }
        
        func delete() -> Future<(), QiitaInfraError> {
            return session.oauthDelete()
                .mapError(QiitaInfraError.QiitaAPIError)
                .flatMap { res in
                    realm {
                        let realm = try GetRealm()
                        realm.beginWrite()
                        realm.delete(realm.objects(AccessTokenEntity))
                        try realm.commitWrite()
                    }
                }
        }
        
        func set(client_id: String, scopes: [String], token: String) {
            
            let realm = try! Realm()
            
            try! realm.write {
                let entity = AccessTokenEntity()
                entity.client_id = client_id
                entity.scopes = scopes
                entity.token = token
                
                realm.add(entity)
            }
        }
    }
}

