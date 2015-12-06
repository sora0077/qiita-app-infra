//
//  RealmHelper.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/12/06.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift


extension Realm {
    
    func objects<T: Object>(type: T.Type) -> (key: AnyObject) -> T? {
        return { key in
            self.objectForPrimaryKey(type, key: key)
        }
    }
}

func GetRealm() throws -> Realm {
    return try Realm(configuration: config)
}

private let config = createConfiguration()

private func createConfiguration() -> Realm.Configuration {
    
    var config = Realm.Configuration()
    config.path = NSURL(fileURLWithPath: config.path!)
        .URLByDeletingLastPathComponent?
        .URLByAppendingPathComponent("infra.realm")
        .path
    config.objectTypes = [
        UserEntity.self,
        AuthenticatedUserEntity.self,
        ItemEntity.self,
        AccessTokenEntity.self,
        CommentEntity.self,
        TaggingEntity.self,
        
        PreferenceEntity.self,
        
        RefUserListEntity.self,
        RefUserListPageEntity.self,
        RefCommentListEntity.self,
        RefCommentListPageEntity.self,
    ]
    return config
}
