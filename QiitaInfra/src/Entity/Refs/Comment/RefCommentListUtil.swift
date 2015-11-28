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

protocol RefCommentListEntityProtocol {
    
    var pages: List<RefCommentListPageEntity> { get }
    
    static var ttl: Attribute<NSDate> { get }
    
    static var ttlLimit: NSDate { get }
}

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
