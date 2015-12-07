//
//  AccessTokenEntity.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/19.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import RealmSwift
import QueryKit

final class AccessTokenEntity: Object, AccessTokenProtocol {
    
    dynamic var id: Int = 1
    
    /// 登録されたAPIクライアントを特定するためのID
    /// example: a91f0396a0968ff593eafdd194e3d17d32c41b1da7b25e873b42e9058058cd9d
    dynamic var client_id: String = ""
    
    /// アクセストークンに許された操作の一覧の保存用フォーマット
    /// example: read_qiita
    private dynamic var _scopes: String = ""
    
    /// アクセストークンを表現する文字列
    /// example: ea5d0a593b2655e9568f144fb1826342292f5c6b7d406fda00577b8d1530d8a5
    dynamic var token: String = ""
    
    override static func ignoredProperties() -> [String] {
        return [
            "scopes"
        ]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension AccessTokenEntity {
    
    static var client_id: Attribute<String> { return Attribute("client_id") }
    
    static var _scopes: Attribute<String> { return Attribute("_scopes") }
    
    static var token: Attribute<String> { return Attribute("token") }
}

extension AccessTokenEntity {
    
    /// アクセストークンに許された操作の一覧
    /// example: read_qiita
    var scopes: [String] {
        get {
            return _scopes.componentsSeparatedByString(",")
        }
        set {
            _scopes = newValue.joinWithSeparator(",")
        }
    }
}

