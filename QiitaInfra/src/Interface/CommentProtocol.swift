//
//  CommentProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import BrightFutures

public protocol CommentRepository {
    
    func itemComments(item: ItemProtocol) -> CommentListRepository
    
    
    func create(item: ItemProtocol, body: String) -> Future<CommentProtocol, QiitaInfraError>
    
    func update(comment: CommentProtocol, body: String) -> Future<CommentProtocol, QiitaInfraError>
    
    func delete(comment: CommentProtocol) -> Future<(), QiitaInfraError>
    
    
    func cache(id: String) throws -> CommentProtocol?
    
    func get(id: String) -> Future<CommentProtocol?, QiitaInfraError>
    
    
    func thank(item: ItemProtocol) -> Future<(), QiitaInfraError>
    
    func unthank(item: ItemProtocol) -> Future<(), QiitaInfraError>
}

/**
 *  投稿に付けられたコメントを表します。
 */
public protocol CommentProtocol {
    
//    typealias User = UserProtocol
    
    /// コメントの内容を表すMarkdown形式の文字列
    /// example: # Example
    var body: String { get }
    
    /// データが作成された日時
    /// example: 2000-01-01T00:00:00+00:00
    var created_at: String { get }
    
    /// コメントの一意なID
    /// example: 3391f50c35f953abfc4f
    var id: String { get }
    
    /// コメントの内容を表すHTML形式の文字列
    /// example: <h1>Example</h1>
    var rendered_body: String { get }
    
    /// データが最後に更新された日時
    /// example: 2000-01-01T00:00:00+00:00
    var updated_at: String { get }
    
    /// Qiita上のユーザを表します。
    var user_id: String { get }
    
}
