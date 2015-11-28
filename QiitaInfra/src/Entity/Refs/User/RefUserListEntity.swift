//
//  RefUserListEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QueryKit
import QiitaKit

protocol RefUserListEntity {
    
    var pages: List<RefUserListPageEntity> { get }
    
    static var ttl: Attribute<NSDate> { get }
    
    static var ttlLimit: NSDate { get }
}

final class RefUserListPageEntity: Object {
    
    let prev_page = RealmOptional<Int>()
    
    let next_page = RealmOptional<Int>()
    
    let users = List<UserEntity>()
}

extension RefUserListPageEntity {
    
    static func create<T: LinkProtocol>(realm: Realm, _ rhs: ([User], LinkMeta<T>)) -> RefUserListPageEntity {
        
        let entity = RefUserListPageEntity()
        entity.prev_page.value = rhs.1.prev?.page
        entity.next_page.value = rhs.1.next?.page
        
        let users = rhs.0.map( { UserEntity.create(realm, $0) })
        realm.add(users, update: true)
        entity.users.appendContentsOf(users)
        
        return entity
    }
}
