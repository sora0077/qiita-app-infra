//: Playground - noun: a place where people can play

import UIKit
import XCPlayground
@testable import QiitaInfra
import QiitaKit
import APIKit

//extension ListItemComments: DebugRequestToken {}

let repos = QiitaRepository(session: QiitaSession(clientId: "", clientSecret: ""))

struct MockItem: ItemProtocol {
    
    /// HTML形式の本文
    /// example: <h1>Example</h1>
    var rendered_body: String = ""
    
    /// Markdown形式の本文
    /// example: # Example
    var body: String = ""
    
    /// この投稿が共同更新状態かどうか (Qiita:Teamでのみ有効)
    var coediting: Bool = false
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    var created_at: String = ""
    
    /// 投稿の一意なID
    /// example: 4bd431809afb1bb99e4f
    var id: String = ""
    
    /// 限定共有状態かどうかを表すフラグ (Qiita:Teamでは無効)
    var `private`: Bool = false
    
    /// 投稿に付いたタグ一覧
    /// example: [{"name"=>"Ruby", "versions"=>["0.0.1"]}]
    var tag_names: [String] = []
    
    /// 投稿のタイトル
    /// example: Example title
    var title: String = ""
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    var updated_at: String = ""
    
    /// 投稿のURL
    /// example: https://qiita.com/yaotti/items/4bd431809afb1bb99e4f
    var url: String = ""
    
    /// Qiita上のユーザを表します。
    var user_id: String = ""
}

var item1 = MockItem()
item1.id = "c686397e4a0f4f11683d"

repos.comment.list(item1).generate().onSuccess { _ in
    print(try? repos.comment.list(item1).values())
    
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

