//
//  CommentListProtocol.swift
//  QiitaInfra
//
//  Created by 林達也 on 2015/11/25.
//  Copyright © 2015年 jp.sora0077. All rights reserved.
//

import Foundation
import BrightFutures

public protocol CommentListRepository {
    
    func values() throws -> [CommentProtocol]
    
    func update() -> Future<[CommentProtocol], QiitaInfraError>
    
    func update(force force: Bool) -> Future<[CommentProtocol], QiitaInfraError>
}

extension CommentListRepository {
    
    func update() -> Future<[CommentProtocol], QiitaInfraError> {
        return update(force: false)
    }
}
