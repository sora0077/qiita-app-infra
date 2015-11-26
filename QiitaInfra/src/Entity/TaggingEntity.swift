//
//  TaggingEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift

/**
 *  投稿とタグとの関連を表します。
 */
final class TaggingEntity: Object {
    
    /// タグを特定するための一意な名前
    /// example: qiita
    dynamic var name: String = ""
    
    ///
    /// example: ["0.0.1"]
    private dynamic var _versions: String = ""
    
    override static func ignoredProperties() -> [String] {
        return [
            "versions"
        ]
    }
}

extension TaggingEntity {
    
    ///
    /// example: ["0.0.1"]
    var versions: [String] {
        get {
            return _versions.componentsSeparatedByString(",")
        }
        set {
            _versions = newValue.joinWithSeparator(",")
        }
    }
}
