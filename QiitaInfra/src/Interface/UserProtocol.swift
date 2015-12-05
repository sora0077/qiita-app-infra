//
//  UserProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import BrightFutures

public protocol UserRepository {
    
    func cache(id: String) throws -> UserProtocol?
    
    func get(id: String) -> Future<UserProtocol?, QiitaInfraError>
    
    func follow(user: UserProtocol) -> Future<(), QiitaInfraError>
    
    func unfollow(user: UserProtocol) -> Future<(), QiitaInfraError>
    
    func following(user: UserProtocol) -> Future<(), QiitaInfraError>
    
    //MARK: - 
    
    func itemStockers(item: ItemProtocol) -> UserListRepository
    
    func userFollowees(user: UserProtocol) -> UserListRepository
    
    func userFollowers(user: UserProtocol) -> UserListRepository
    
    func users() -> UserListRepository
}

/**
 *  Qiita上のユーザを表します。
 */
@objc
public protocol UserProtocol {
    
    /// 自己紹介文
    /// example: Hello, world.
    var description_qiita: String? { get }
    
    /// Facebook ID
    /// example: yaotti
    var facebook_id: String? { get }
    
    /// このユーザがフォローしているユーザの数
    /// example: 100
    var followees_count: Int { get }
    
    /// このユーザをフォローしているユーザの数
    /// example: 200
    var followers_count: Int { get }
    
    /// GitHub ID
    /// example: yaotti
    var github_login_name: String? { get }
    
    /// ユーザID
    /// example: yaotti
    var id: String { get }
    
    /// このユーザが qiita.com 上で公開している投稿の数 (Qiita:Teamでの投稿数は含まれません)
    /// example: 300
    var items_count: Int { get }
    
    /// LinkedIn ID
    /// example: yaotti
    var linkedin_id: String? { get }
    
    /// 居住地
    /// example: Tokyo, Japan
    var location: String? { get }
    
    /// 設定している名前
    /// example: Hiroshige Umino
    var name: String? { get }
    
    /// 所属している組織
    /// example: Increments Inc
    var organization: String? { get }
    
    /// ユーザごとに割り当てられる整数のID
    /// example: 1
    var permanent_id: Int { get }
    
    /// 設定しているプロフィール画像のURL
    /// example: https://si0.twimg.com/profile_images/2309761038/1ijg13pfs0dg84sk2y0h_normal.jpeg
    var profile_image_url: String { get }
    
    /// Twitterのスクリーンネーム
    /// example: yaotti
    var twitter_screen_name: String? { get }
    
    /// 設定しているWebサイトのURL
    /// example: http://yaotti.hatenablog.com
    var website_url: String? { get }
    
}