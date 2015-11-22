//
//  AccessTokenRepository.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/20.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

extension QiitaRepository {
    
    final class AccessToken: AccessTokenRepository {
        
        var value: AccessTokenProtocol? {
            let realm = try? Realm()
            return realm?.objects(AccessTokenEntity).first
        }
    }
}

