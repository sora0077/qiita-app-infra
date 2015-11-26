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
    
    static var ttl: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}


final class RefItemCommentList: Object {
    
    dynamic var item_id: String = ""
    
    let pages = List<RefItemCommentListPage>()
    /// キャッシュされた日付
    dynamic var ttl: NSDate = NSDate()
    
    override static func primaryKey() -> String? {
        return "item_id"
    }
}

final class RefItemCommentListPage: Object {
    
    let prev_page = RealmOptional<Int>()
    
    let next_page = RealmOptional<Int>()
    
    let comments = List<CommentEntity>()
}

import QiitaKit

extension RefItemCommentList {
    
    static func create(realm: Realm, _ item_id: String, _ rhs: ([Comment], LinkMeta<ListItemComments>)) -> RefItemCommentList {
        
        let entity = RefItemCommentList()
        entity.pages.append(RefItemCommentListPage.create(realm, rhs))
        entity.item_id = item_id
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttl: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}

extension RefItemCommentListPage {
    
    static func create(realm: Realm, _ rhs: ([Comment], LinkMeta<ListItemComments>)) -> RefItemCommentListPage {
        
        let entity = RefItemCommentListPage()
        entity.prev_page.value = rhs.1.prev?.page
        entity.next_page.value = rhs.1.next?.page
        
        let comments = rhs.0.map( { CommentEntity.create(realm, $0) })
        realm.add(comments, update: true)
        entity.comments.appendContentsOf(comments)
        
        return entity
    }
}
