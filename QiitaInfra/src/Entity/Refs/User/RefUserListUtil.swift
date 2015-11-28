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

protocol RefUserListEntityProtocol {
    
    var pages: List<RefUserListPageEntity> { get }
    
    static var ttl: Attribute<NSDate> { get }
    
    static var ttlLimit: NSDate { get }
}


final class RefUserListEntity: Object, RefUserListEntityProtocol {
    
    dynamic var key: String = ""
    
    let pages = List<RefUserListPageEntity>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

extension RefUserListEntity {
    
    static var key: Attribute<String> { return Attribute("key") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
    
    static var pages: Attribute<RefUserListPageEntity> { return Attribute("pages") }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}


extension RefUserListEntity {
    
    static func create<T: LinkProtocol>(realm: Realm, _ key: String, _ rhs: ([User], LinkMeta<T>)) -> RefUserListEntity {
        
        let entity = RefUserListEntity()
        entity.pages.append(RefUserListPageEntity.create(realm, rhs))
        entity.key = key
        
        entity.ttl = NSDate()
        
        return entity
    }
}

//MARK: -

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
