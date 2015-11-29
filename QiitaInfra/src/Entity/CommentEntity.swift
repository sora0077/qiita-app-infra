//
//  CommentEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  投稿に付けられたコメントを表します。
 */
final class CommentEntity: Object, CommentProtocol {
    
    /// コメントの内容を表すMarkdown形式の文字列
    /// example: # Example
    dynamic var body: String = ""
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    dynamic var created_at: String = ""
    
    /// コメントの一意なID
    /// example: 3391f50c35f953abfc4f
    dynamic var id: String = ""
    
    /// コメントの内容を表すHTML形式の文字列
    /// example: <h1>Example</h1>
    dynamic var rendered_body: String = ""
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    dynamic var updated_at: String = ""
    
    /// Qiita上のユーザを表します。
    dynamic var user: UserEntity! = nil
    
    dynamic var ttl: NSDate = NSDate()
    
    var user_id: String {
        return user.id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

import QiitaKit
import QueryKit

extension CommentEntity {
    
    static var id: Attribute<String> { return Attribute("id") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
}

extension CommentEntity {
    
    static func create(realm: Realm, _ rhs: Comment) -> CommentEntity {
        
        let entity = CommentEntity()
        
        entity.id = rhs.id
        entity.body = rhs.body
        entity.created_at = rhs.created_at
        entity.rendered_body = rhs.rendered_body
        entity.updated_at = rhs.updated_at
        entity.user = UserEntity.create(realm, rhs.user)
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: cacheTimeoutInterval)
    }
}
