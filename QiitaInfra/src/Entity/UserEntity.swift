//
//  UserEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  Qiita上のユーザを表します。
 */
final class UserEntity: Object, UserProtocol {
    
    /// 自己紹介文
    /// example: Hello, world.
    dynamic var description_qiita: String? = nil
    
    /// Facebook ID
    /// example: yaotti
    dynamic var facebook_id: String? = nil
    
    /// このユーザがフォローしているユーザの数
    /// example: 100
    dynamic var followees_count: Int = 0
    
    /// このユーザをフォローしているユーザの数
    /// example: 200
    dynamic var followers_count: Int = 0
    
    /// GitHub ID
    /// example: yaotti
    dynamic var github_login_name: String? = nil
    
    /// ユーザID
    /// example: yaotti
    dynamic var id: String = ""
    
    /// このユーザが qiita.com 上で公開している投稿の数 (Qiita:Teamでの投稿数は含まれません)
    /// example: 300
    dynamic var items_count: Int = 0
    
    /// LinkedIn ID
    /// example: yaotti
    dynamic var linkedin_id: String? = nil
    
    /// 居住地
    /// example: Tokyo, Japan
    dynamic var location: String? = nil
    
    /// 設定している名前
    /// example: Hiroshige Umino
    dynamic var name: String? = nil
    
    /// 所属している組織
    /// example: Increments Inc
    dynamic var organization: String? = nil
    
    /// ユーザごとに割り当てられる整数のID
    /// example: 1
    dynamic var permanent_id: Int = 0
    
    /// 設定しているプロフィール画像のURL
    /// example: https://si0.twimg.com/profile_images/2309761038/1ijg13pfs0dg84sk2y0h_normal.jpeg
    dynamic var profile_image_url: String = ""
    
    /// Twitterのスクリーンネーム
    /// example: yaotti
    dynamic var twitter_screen_name: String? = nil
    
    /// 設定しているWebサイトのURL
    /// example: http://yaotti.hatenablog.com
    dynamic var website_url: String? = nil
    
    
    dynamic var ttl: NSDate = NSDate()

    
    override static func primaryKey() -> String? {
        return "id"
    }
}

import QiitaKit
import QueryKit

extension UserEntity {
    
    static var id: Attribute<String> { return Attribute("id") }
    
    static var ttl: Attribute<NSDate> { return Attribute("ttl") }
}

extension UserEntity {
    
    static func create(realm: Realm, _ rhs: User) -> UserEntity {
        
        let entity = UserEntity()
        
        entity.id = rhs.id
        entity.description_qiita = rhs.description
        entity.facebook_id = rhs.facebook_id
        entity.followees_count = rhs.followees_count
        entity.github_login_name = rhs.github_login_name
        entity.items_count = rhs.items_count
        entity.linkedin_id = rhs.linkedin_id
        entity.location = rhs.location
        entity.name = rhs.name
        entity.organization = rhs.organization
        entity.permanent_id = rhs.permanent_id
        entity.profile_image_url = rhs.profile_image_url
        entity.twitter_screen_name = rhs.twitter_screen_name
        entity.website_url = rhs.website_url
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttlLimit: NSDate {
        return NSDate(timeIntervalSinceNow: cacheTimeoutInterval)
    }
}
