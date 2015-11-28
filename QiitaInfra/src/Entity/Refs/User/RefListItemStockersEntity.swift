//
//  RefListItemStockersEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

final class RefListItemStockersEntity: Object, RefUserListEntity {
    
    dynamic var item_id: String = ""
    
    let pages = List<RefUserListPageEntity>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "item_id"
    }
}

import QiitaKit
import QueryKit

extension RefListItemStockersEntity {
    
    static var item_id: Attribute<String> { return Attribute("item_id") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
    
    static var pages: Attribute<RefUserListPageEntity> { return Attribute("pages") }
    
}

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
