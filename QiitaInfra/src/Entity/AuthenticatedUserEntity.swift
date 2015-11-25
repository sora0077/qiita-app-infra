//
//  AuthenticatedUser.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/23.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QiitaKit

/**
 *  現在のアクセストークンで認証中のユーザを表します。通常のユーザ情報よりも詳細な情報を含んでいます。
 */
final class AuthenticatedUserEntity: Object, AuthenticatedUserProtocol {
    
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
    
    /// 1ヶ月あたりにQiitaにアップロードできる画像の総容量
    /// example: 1048576
    dynamic var image_monthly_upload_limit: Int = 0
    
    /// その月にQiitaにアップロードできる画像の残りの容量
    /// example: 524288
    dynamic var image_monthly_upload_remaining: Int = 0
    
    /// Qiita:Team専用モードに設定されているかどうか
    dynamic var team_only: Bool = false
    
    /// キャッシュされた日付
    dynamic var ttl: NSDate?
}

extension AuthenticatedUserEntity {
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func create(rhs: AuthenticatedUser) -> AuthenticatedUserEntity {
        
        let entity = AuthenticatedUserEntity()
        
        entity.ttl = NSDate()
        
        return entity
    }
    
    static var ttl: NSDate {
        return NSDate(timeIntervalSinceNow: -300)
    }
}
