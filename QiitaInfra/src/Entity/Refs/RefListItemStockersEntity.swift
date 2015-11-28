//
//  RefListItemStockersEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

final class RefListItemStockersEntity: Object {
    
    dynamic var item_id: String = ""
    
    let pages = List<RefUserListPageEntity>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "item_id"
    }
}

final class RefUserListPageEntity: Object {
    
    let prev_page = RealmOptional<Int>()
    
    let next_page = RealmOptional<Int>()
    
    let users = List<UserEntity>()
}


import QiitaKit

extension RefListItemStockersEntity {
    
    static func create<T: LinkProtocol>(realm: Realm, _ item_id: String, _ rhs: ([User], LinkMeta<T>)) -> RefListItemStockersEntity {
        
        let entity = RefListItemStockersEntity()
        entity.pages.append(RefUserListPageEntity.create(realm, rhs))
        entity.item_id = item_id
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
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