//
//  ItemProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import BrightFutures

public protocol ItemRepository {
    
    func cache(id: String) throws -> ItemProtocol?
    
    func get(id: String) -> Future<ItemProtocol?, QiitaInfraError>
    
    func create(body: String, title: String, coediting: Bool, gist: Bool, tweet: Bool, `private`: Bool, tags: [String]) -> Future<ItemProtocol?, QiitaInfraError>
    //MARK: -
}

/**
 *  ユーザからの投稿を表します。
 */
public protocol ItemProtocol {
    
    /// HTML形式の本文
    /// example: <h1>Example</h1>
    var rendered_body: String { get }
    
    /// Markdown形式の本文
    /// example: # Example
    var body: String { get }
    
    /// この投稿が共同更新状態かどうか (Qiita:Teamでのみ有効)
    var coediting: Bool { get }
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    var created_at: String { get }
    
    /// 投稿の一意なID
    /// example: 4bd431809afb1bb99e4f
    var id: String { get }
    
    /// 限定共有状態かどうかを表すフラグ (Qiita:Teamでは無効)
    var `private`: Bool { get }
    
    /// 投稿に付いたタグ一覧
    /// example: [{"name"=>"Ruby", "versions"=>["0.0.1"]}]
    var tag_names: [String] { get }
    
    /// 投稿のタイトル
    /// example: Example title
    var title: String { get }
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    var updated_at: String { get }
    
    /// 投稿のURL
    /// example: https://qiita.com/yaotti/items/4bd431809afb1bb99e4f
    var url: String { get }
    
    /// Qiita上のユーザを表します。
    var user_id: String { get }
    
}
