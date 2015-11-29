//
//  RefCommentListUtil.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/28.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QueryKit
import QiitaKit

protocol RefCommentListEntityProtocol: class {
    
    var pages: List<RefCommentListPageEntity> { get }
    
    var version: Int { get set }
    
    var ttl: NSDate { get set }
    
    static var version: Attribute<Int> { get }
    
    static var ttl: Attribute<NSDate> { get }
    
    static var ttlLimit: NSDate { get }
}

final class RefCommentListEntity: Object, RefCommentListEntityProtocol {
    
    dynamic var key: String = ""
    
    dynamic var version: Int = 0
    
    let pages = List<RefCommentListPageEntity>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "key"
    }
}

extension RefCommentListEntity {
    
    static var key: Attribute<String> { return Attribute("key") }
    
    static var version: Attribute<Int> { return Attribute("version") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
    
    static var pages: Attribute<RefCommentListPageEntity> { return Attribute("pages") }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}


extension RefCommentListEntity {
    
    static func create<T: LinkProtocol>(realm: Realm, _ key: String, _ rhs: ([Comment], LinkMeta<T>)) -> Self {
        
        let entity = self.init()
        entity.pages.append(RefCommentListPageEntity.create(realm, rhs))
        entity.key = key
        
        entity.ttl = NSDate()
        
        return entity
    }
}

//MARK: - 

final class RefCommentListPageEntity: Object {
    
    let prev_page = RealmOptional<Int>()
    
    let next_page = RealmOptional<Int>()
    
    let comments = List<CommentEntity>()
}

extension RefCommentListPageEntity {
    
    static func create<T: LinkProtocol>(realm: Realm, _ rhs: ([Comment], LinkMeta<T>)) -> RefCommentListPageEntity {
        
        let entity = RefCommentListPageEntity()
        entity.prev_page.value = rhs.1.prev?.page
        entity.next_page.value = rhs.1.next?.page
        
        let comments = rhs.0.map( { CommentEntity.create(realm, $0) })
        realm.add(comments, update: true)
        entity.comments.appendContentsOf(comments)
        
        return entity
    }
}
