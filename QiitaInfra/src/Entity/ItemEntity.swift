//
//  ItemEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  ユーザからの投稿を表します。
 */
final class ItemEntity: Object, ItemProtocol {
    
    /// HTML形式の本文
    /// example: <h1>Example</h1>
    dynamic var rendered_body: String = ""
    
    /// Markdown形式の本文
    /// example: # Example
    dynamic var body: String = ""
    
    /// この投稿が共同更新状態かどうか (Qiita:Teamでのみ有効)
    dynamic var coediting: Bool = false
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    dynamic var created_at: String = ""
    
    /// 投稿の一意なID
    /// example: 4bd431809afb1bb99e4f
    dynamic var id: String = ""
    
    /// 限定共有状態かどうかを表すフラグ (Qiita:Teamでは無効)
    dynamic var `private`: Bool = false
    
    /// 投稿に付いたタグ一覧
    /// example: [{"name"=>"Ruby", "versions"=>["0.0.1"]}]
    let tags = List<TaggingEntity>()
    
    /// 投稿のタイトル
    /// example: Example title
    dynamic var title: String = ""
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    dynamic var updated_at: String = ""
    
    /// 投稿のURL
    /// example: https://qiita.com/yaotti/items/4bd431809afb1bb99e4f
    dynamic var url: String = ""
    
    /// Qiita上のユーザを表します。
    dynamic var user: UserEntity! = nil
    
    var tag_names: [String] {
        return tags.map { $0.name }
    }
    
    var user_id: String {
        return user.id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}