//
//  RefListItemCommentsEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit
import QueryKit

final class RefListItemCommentsEntity: Object, RefCommentListEntityProtocol {
    
    dynamic var item_id: String = ""
    
    let pages = List<RefCommentListPageEntity>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "item_id"
    }
}

extension RefListItemCommentsEntity {
    
    static var item_id: Attribute<String> { return Attribute("item_id") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
    
    static var pages: Attribute<RefCommentListPageEntity> { return Attribute("pages") }
}

extension RefListItemCommentsEntity {
    
    static func create(realm: Realm, _ item_id: String, _ rhs: ([Comment], LinkMeta<ListItemComments>)) -> RefListItemCommentsEntity {
        
        let entity = RefListItemCommentsEntity()
        entity.pages.append(RefCommentListPageEntity.create(realm, rhs))
        entity.item_id = item_id
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}
